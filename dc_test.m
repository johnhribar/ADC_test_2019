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
LA = openLA('sine_wav_dc.ala');

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
% data = dec2hex(5,4); % Test port Conf, set to 5 for 50 ohm termination, 4 otherwise
writeNi845x(ni845x, 4, '0049', '0011');
adc_str = ['ADC', num2str(adc), '_CONFIG_RAMP2.txt'];
registerWrite(ni845x, adc_str, 'ADC')
% data = dec2hex(3200, 4);
% writeNi845x(ni845x, 4, '005B', '0088'); % ADC correction logic

% writeNi845x(ni845x, 4, '005F', '00FF');
% writeNi845x(ni845x, 4, '0047', '00FF');
% writeNi845x(ni845x, CS.RFIC, '0020', '0000');
% signals = getSignal(LA, adc_evens, adc_odds, clk_str, clock);
% plot(signals.constructed, ':*')

for i = 0:7
    turn_on_adc = dec2hex(2^i,4);
    turn_off_adcs = dec2hex((255-2^i),4);
    writeNi845x(ni845x, CS.RFIC, '005F', turn_on_adc);
    writeNi845x(ni845x, CS.RFIC, '0047', turn_on_adc);
    writeNi845x(ni845x, CS.RFIC, '0020', turn_off_adcs);
    pause(.5);
    signals(i+1) = getSignalClocked(LA, adc_evens, adc_odds);
%     signals(i+1) = getSignal(LA, adc_evens, adc_odds, clk_str, clock);
end

for i = 1:8
    switch i
        case 1
            format_str = 'y:*';
        case 2
            format_str = 'm:*';
        case 3
            format_str = 'c:*';
        case 4
            format_str = 'r:*';
        case 5
            format_str = 'g:*';
        case 6
            format_str = 'b:*';
        case 7
            format_str = 'k:*';
        case 8
            format_str = ':*';
    end
    subplot(4,2,i);
    plot(signals(i).constructed, format_str)
end

figure;
turn_on_adc = '00FF';
turn_off_adcs = '0000';
writeNi845x(ni845x, CS.RFIC, '005F', turn_on_adc);
writeNi845x(ni845x, CS.RFIC, '0047', turn_on_adc);
writeNi845x(ni845x, CS.RFIC, '0020', turn_off_adcs);
pause(.5);
combined_signal = getSignalClocked(LA, adc_evens, adc_odds);
% combined_signal = getSignal(LA, adc_evens, adc_odds, clk_str, clock);

% adc_str = ['ADC', num2str(adc), '_CONFIG_SINE.txt'];
% registerWrite(ni845x, adc_str, 'ADC')
% signal = getSignal(LA, adc_evens, adc_odds, clk_str, clock);
% maxmin = zeros(2,9);
% average = zeros(1,9);
% maxmin(1,9) = max(signal.constructed);
% maxmin(2,9) = min(signal.constructed);
% average(9) = round(mean(signal.constructed));
% for i = 1:8
%     n = 1;
%     for j = i:8:length(signal.constructed)
%         combined_signal(i).y(n) = signal.constructed(j);
%         combined_signal(i).x(n) = j;
%         n = n + 1;
%     end
%     maxmin(1,i) = max(combined_signal(i).y);
%     maxmin(2,i) = min(combined_signal(i).y);
%     average(i) = round(mean(combined_signal(i).y));
% end
% deltas(1,:) = maxmin(1,:) - average;
% deltas(2,:) = average - maxmin(2,:);
% 
% subplot(3,3,9);
% plot(signal.constructed);
% figure;
% plot(combined_signal(1).x, combined_signal(1).y,'y',...
%     combined_signal(2).x, combined_signal(2).y,'m',...
%     combined_signal(3).x, combined_signal(3).y,'c',...
%     combined_signal(4).x, combined_signal(4).y,'r',...
%     combined_signal(5).x, combined_signal(5).y,'g',...
%     combined_signal(6).x, combined_signal(6).y,'b',...
%     combined_signal(7).x, combined_signal(7).y,'w',...
%     combined_signal(8).x, combined_signal(8).y,'k')
%     
% Free memory we're no longer using
delete(LA.hConnect)
closeNi845x(ni845x);