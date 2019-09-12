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
adc_str = ['ADC', num2str(adc), '_CONFIG_SINE.txt'];
registerWrite(ni845x, adc_str, 'ADC')
load('calibration_variables.mat');

for i = 1:12
    signals(i) = getSignal(LA, adc_evens, adc_odds, clk_str, clock);
    disp('Toggle RF')
    pause
end

cols = 1;
rows = 1;
for i = 1:length(signals)
%     factors = factor(length(signals));
%     for j = 1:floor(length(signals)/2)
%         cols = cols * factors(j);
%     end
%     for j = j+1:length(signals)
%         rows = rows * factors(j);
%     end
    subplot(4,3,i);
    plot(signals(i).constructed,':*')
end

% Free memory we're no longer using
delete(LA.hConnect)
closeNi845x(ni845x);