function [values, signal] = alignData(ni845x, LA, CS, adc)

% Places ADC in static value mode and sets up RCASICs
adc_str = ['ADC', num2str(adc.num), '_CONFIG_UNIQUE.txt'];
registerWrite(ni845x, adc_str, 'ADC')
registerWrite(ni845x, 'RCASIC_CONF.txt', 'RCASIC')

%% Channel Stuff
% Runs the logic analyzer and updates CH0A and CH0B
[CH0A, CH0B] = update(LA, true);

% Runs function to identify data lines and align them
[adc_odds, adc_evens, first_12_top, first_12_bot,...
    CH0A, CH0B] = identifyAndAlign(ni845x, LA, CS, CH0A, CH0B, adc.num, adc.cycle, adc.sample_ratio);
% Figures out the offset between data lines
line_offset = lineOffset(CH0A.vec, CH0B.vec, adc_odds, adc_evens,...
    first_12_top, first_12_bot, adc.cycle);

[CH0A, CH0B] = lineAdjust(ni845x, LA, line_offset.ordered, CS, adc.num);

first_12_top = first12(CH0A.vec, adc.cycle);
first_12_bot = first12(CH0B.vec, adc.cycle);

line_offset_adj = lineOffset(CH0A.vec, CH0B.vec, adc_odds, adc_evens,...
    first_12_top, first_12_bot, adc.cycle);

status = 'Starting fine calibration...';
disp(status)
while sum(line_offset_adj.ordered, 'all') > 5 || line_offset_adj.max > 1
    
    [CH0A, CH0B] = finalAdjust(ni845x, CS, LA, line_offset, line_offset_adj, adc.num);
    line_offset = line_offset_adj;
    first_12_top = first12(CH0A.vec, adc.cycle);
    first_12_bot = first12(CH0B.vec, adc.cycle);
    line_offset_adj = lineOffset(CH0A.vec, CH0B.vec, adc_odds, adc_evens,...
    first_12_top, first_12_bot, adc.cycle);
end
status = 'Finished.';
disp(status)

%% Clock Stuff
[CLK0A, CLK0B] = getClock(LA, false);

[CH0A, CH0B, clock_edges, clock, clk_str] = getClockEdges(ni845x, CS,...
    LA, CLK0A, CLK0B, CH0A, adc_evens(1), adc.sample_ratio, adc.cycle, adc.num);

% load('diffs.mat');

status = ['Using clock ', clock];
disp(status);
status = ['Using edge ', clk_str];
disp(status);
%% Reconstruction Stuff
CH0A0B = [CH0A.vec;CH0B.vec];

% Reconstruct vectors, sorting by odds and evens and appropriately offset

clocked_odd = zeros(12, length(clock_edges));
clocked_even = zeros(12, length(clock_edges));
for i = 1:length(clock_edges)
    for j = 1:12
        clocked_odd(j,i) = CH0A0B(adc_odds(j), clock_edges(i));
        clocked_even(j,i) = CH0A0B(adc_evens(j), clock_edges(i));
    end
end

% Create last vectors to hold values of signals 
oddline2s = zeros(12, length(clocked_odd));
evenline2s = zeros(12, length(clocked_even));
for n = 1:12
    oddline2s(n,:) = 2^(n-1).*clocked_odd(n,:);
    evenline2s(n,:) = 2^(n-1).*clocked_even(n,:);
end
% Calculate the values of each ADC
values=[sum(oddline2s);sum(evenline2s)];

signal = zeros(1, length(values)*2);
j = 1;
for i = 1:length(values)
    signal(j) = values(1,i);
    signal(j+1) = values(2,i);
    j = j+2;
end

save('calibration_variables.mat','adc_odds','adc_evens','clock','clk_str');