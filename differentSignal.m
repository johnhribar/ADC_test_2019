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
adc = 1;

% Estabishes communication with peripherals
ni845x = openNi845x();
% LA_config = ['synchronous_', num2str(adc), '.ala'];
LA_config = ['config', num2str(adc), '.ala'];
LA = openLA(LA_config);

% Defines chips selects and resets the board
CS.RC0A = 0;
CS.RC0B = 1;
CS.RC1B = 2;
CS.RC1A = 3;
CS.RFIC = 4;
CS.RST = 5;
reset = '0000';

% Places ADC in static value mode and sets up RCASICs
adc_str = ['ADC', num2str(adc), '_CONFIG_FIRST.txt']; % Never use CONFIG_UNIQUE
% adc_str = ['ADC', num2str(adc), 'OneZero/1.txt']; % Never use CONFIG_UNIQUE
registerWrite(ni845x, adc_str, 'ADC')
registerWrite(ni845x, 'RCASIC_CONF.txt', 'RCASIC')
load_str = ['calibration_variables',num2str(adc),'.mat'];
load(load_str);
signal = getSignalClocked(LA, adc_evens, adc_odds);
signal_array = signal.constructed(501:508);
signal_hex = dec2hex(transpose(signal_array),4);
signal_hex = cellstr(signal_hex);
% signal = getSignal(LA, adc_evens, adc_odds, clk_str, clock);
% 
% plot(signal.constructed,':*');
% signal.scaled = zeros(1,length(signal.constructed)*10);
% signal.scaled(signal.scaled==0) = nan;
% for i = 10:10:length(signal.scaled)
%     signal.scaled(i) = signal.constructed(i/10);
% end
% subADC = 8;
% new_signal = zeros(1, length(signal.scaled));
% for i = subADC*10:80:length(signal.scaled)
%     new_signal(i) = signal.scaled(i);
% end

% Free memory we're no longer using
delete(LA.hConnect)

% calllib('ni845x_lib','ni845xSpiConfigurationClose', ni845x.SPIHandle);
% calllib('ni845x_lib','ni845xClose', ni845x.DeviceHandle);
% unloadlibrary ni845x_lib;
% clear ni845x;