% Read data from ADC after determining RCASIC delays
% John Hribar and Jacob Orkis
% May 2019

%% Housekeeping
clc
clear
close all

%% Setup
% prompt = 'Enter ADC (1 or 2): ';
% adc = input(prompt);
% if adc ~= 1 && adc~=2
%     adc = 1;
% end
adc = 2;

% Estabishes communication with peripherals
ni845x = openNi845x();
LA_config = ['synchronous_', num2str(adc), '.ala'];
LA = openLA(LA_config);

% Defines chips selects and resets the board
CS.RC0A = 0;
CS.RC0B = 1;
CS.RC1B = 2;
CS.RC1A = 3;
CS.RFIC = 4;
CS.RST = 5;
reset = '0000';
load_str = ['calibration_variables',num2str(adc),'.mat'];
load(load_str);

% Places ADC in static value mode and sets up RCASICs
signal_array = ones(32,8);
for i = 1:32
    adc_str = ['ADC', num2str(adc), 'OneZero/',num2str(i), '.txt'];
%     adc_str = ['ADC', num2str(adc), 'OneZero/',num2str(i), ' - Copy', '.txt'];
%     adc_str = ['ADC', num2str(adc), 'OneZero/',num2str(i), ' - Copy (2)', '.txt'];
    registerWrite(ni845x, adc_str, 'ADC')
    pause(0.5);
    signal = getSignalClocked(LA, adc_evens, adc_odds);
    signal_array(i,:) = signal.constructed(501:508);
end
signal_hex = dec2hex(transpose(signal_array),4);
signal_hex = cellstr(signal_hex);
signal_hex = reshape(signal_hex, 8, 32);

% Free memory we're no longer using
delete(LA.hConnect)
