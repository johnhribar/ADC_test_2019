function [values, signal, aligned_values] = alignDataClocked(ni845x, LA, CS, adc, version)

% Places ADC in static value mode and sets up RCASICs
adc_str = ['ADC', num2str(adc.num), '_CONFIG_UNIQUE.txt'];
registerWrite(ni845x, adc_str, 'ADC')
registerWrite(ni845x, 'RCASIC_CONF.txt', 'RCASIC')

%% Channel Stuff

% Runs function to identify data lines and align them
[adc_odds, adc_evens, first_12_top, first_12_bot,...
    CH0A, CH0B, aligned_values] = identifyAndAlignClocked(ni845x, LA, CS, adc, version);

% Figures out the offset between data lines
line_offset = lineOffset(CH0A.vec, CH0B.vec, adc_odds, adc_evens,...
    first_12_top, first_12_bot, adc.cycle);

% Uses that offset to adjust the delay on the individual RCASIC lines
[CH0A, CH0B, first_12_top, first_12_bot] = lineAdjust(ni845x, LA, line_offset.ordered, CS, adc);

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
[~, CLK0B] = getClock(LA, false);
alignClock(ni845x, CS.RC0B, CLK0B, CH0A, adc_evens(1));

%% Reconstruction Stuff
LA_config = ['config', num2str(adc.num), '.ala'];
LA = openLA(LA_config);
[CH0A, CH0B] = update(LA, true);

CH0A0B = [CH0A.vec;CH0B.vec];

% Reconstruct vectors, sorting by odds and evens and appropriately offset

clocked_odd = zeros(12, length(CH0A0B));
clocked_even = zeros(12, length(CH0A0B));
for j = 1:12
    clocked_odd(j,:) = CH0A0B(adc_odds(j),:);
    clocked_even(j,:) = CH0A0B(adc_evens(j),:);
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

ADC_even_lines_A = zeros(1,6);
ADC_even_lines_B = zeros(1,6);
ADC_odd_lines_A = zeros(1,6);
ADC_odd_lines_B = zeros(1,6);

for i = 1:6
    ADC_even_lines_A(i) = adc.CH0A_lines(adc_evens(i));
    ADC_even_lines_B(i) = adc.CH0B_lines(adc_evens(i+6)-12);
    ADC_odd_lines_A(i) = adc.CH0A_lines(adc_odds(i));
    ADC_odd_lines_B(i) = adc.CH0B_lines(adc_odds(i+6)-12);
end
save_str = ['calibration_variables', num2str(adc.num), '.mat'];
save(save_str,'adc_odds','adc_evens');