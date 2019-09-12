% Read data from ADC after determining RCASIC delays
% John Hribar and Jacob Orkis
% May 2019

%% Housekeeping
clc
clear
close all

%% Setup
% Estabishes communication with peripherals
ni845x = openNi845x();
LA = openLA('sine_wave.ala');

% Defines chips selects and resets the board
CS.RC0A = 0;
CS.RC0B = 1;
CS.RC1B = 2;
CS.RC1A = 3;
CS.RFIC = 4;
CS.RST = 5;
reset = '0000';

% prompt = 'Enter ADC (1 or 2): ';
% adc = input(prompt);
% if adc ~= 1 && adc~=2
%     adc = 1;
% end
adc = 1;

% Places ADC in static value mode and sets up RCASICs
load('calibration_variables.mat');
data = dec2hex(5,4); % Test port Conf, set to 5 for 50 ohm termination, 4 otherwise
writeNi845x(ni845x, CS.RFIC, '0049', data); 
adc_str = ['ADC', num2str(adc), '_CONFIG_SINE1.txt'];
registerWrite(ni845x, adc_str, 'ADC')
max_tries = 12;
data = zeros(1, max_tries);
% data = [3600, 3700, 3800, 3900];
for i = 1:max_tries
    data(i) = randi([0,4095]);
    data_hex = dec2hex(data(i),4);
    writeNi845x(ni845x, 4, '005B', data_hex); % ADC correction logic
    signals(i) = getSignal(LA, adc_evens, adc_odds, clk_str, clock);
end

cols = 1;
rows = 1;
factors = factor(length(signals));
for j = 1:ceil(length(factors)/2)
    cols = cols * factors(j);
end
for j = j+1:length(factors)
    rows = rows * factors(j);
end

for i = 1:length(signals)
    subplot(cols,rows,i);
    signals(i).x_constr = 1:length(signals(i).constructed);
    plot(signals(i).x_constr, signals(i).constructed,':*')
end
start_sig = zeros(1, length(signals));
for i = 1:length(signals)
    prompt = ['Input number for graph ', num2str(i), ': '];
    start_sig(i) = input(prompt);
end
start_sig = mod(start_sig, 8) + 8;
for i = 1:length(signals)
    n = 1;
    for j = start_sig(i):8:length(signals(i).constructed)
        signals(i).x(n) = j;
        signals(i).y(n) = signals(i).constructed(j);
        n = n + 1;
    end
end
maxmin = zeros(2,length(signals));
average = zeros(1,length(signals));
for i = 1:length(signals)
    subplot(cols,rows,i);
    plot(signals(i).x_constr, signals(i).constructed,':*',...
        signals(i).x, signals(i).y, 'g--o')
    maxmin(1,i) = max(signals(i).y);
    maxmin(2,i) = min(signals(i).y);
    average(i) = round(mean(signals(i).y));
end
deltas(1,:) = maxmin(1,:) - average;
deltas(2,:) = average - maxmin(2,:);

% Free memory we're no longer using
delete(LA.hConnect)
closeNi845x(ni845x);