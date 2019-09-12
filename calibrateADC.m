% Automatically calibrates ADC AB buffers for SPEAR ADC
% Jacob Orkis and John Hribar
% 6.10.2019
% Housekeeping
clear;
clc;
close all;

% open ni845x object to enable SPI communication
ni845x = openNi845x();

% open variable power supply and precision multimeter
% [powerSupply, multimeter] = openInstruments();

% prompt = 'Enter ADC (1 or 2): ';
% adc.num = input(prompt);
% if adc.num ~= 1 && adc.num~=2
%     adc.num = 1;
% end
adc.num = 1;
% specify the input clock for the ADC to tell us how many samples per clock
% we're getting from the logic analyzer
% prompt = 'Enter the clock rate (in GHz): ';
% adc.input_clock = input(prompt);
% adc.input_clock = adc.input_clock * 1e9;
adc.input_clock = 4e9;

adc.clock_division = 4;
adc.output_clock = adc.input_clock / adc.clock_division;
adc.sample_rate = 5e9;
adc.sample_ratio = adc.sample_rate / adc.output_clock;
adc.cycle = floor(adc.sample_ratio * adc.clock_division);
% prompt = 'Enter the version number: ';
% version = input(prompt,'s');
version = getVersion();
% open Logic analyzer
LA_config = ['config', num2str(adc.num), '.ala'];
LA = openLA(LA_config);

% Defines chips selects and resets the board
CS.RC0A = 0;
CS.RC0B = 1;
CS.RC1B = 2;
CS.RC1A = 3;
CS.RFIC = 4;
CS.RST = 5;

status = ['Running tests for ADC ', num2str(adc.num), '...'];
disp(status)

switch adc.num
    case 1
        adc.test_enable = '0004';
        adc.cal_idac = '0057';
        adc.cal_val_lo = '0060';
        adc.cal_val_hi = '0061';
        adc.cal_r_odd_hi = '0066';
        adc.cal_l_odd_hi = '0068';
        adc.cal_r_even_hi = '006A';
        adc.cal_l_even_hi = '006C';
        adc.cal_r_odd_lo = '0067';
        adc.cal_l_odd_lo = '0069';
        adc.cal_r_even_lo = '006B';
        adc.cal_l_even_lo = '006D';
        adc.mtha_idac = '0091';
        adc.ab_idac = '0092';
        adc.vref824_14 = '0043';
        adc.vref824_58 = '0094';
        adc.localBuff_12 = '0062';
        adc.localBuff_34 = '0063';
        adc.localBuff_56 = '0064';
        adc.localBuff_78 = '0065';
        adc.delay1 = '0000';
        adc.delay2 = '0001';
        adc.delay3 = '0002';
        adc.delay4 = '0003';
        adc.delay5 = '0004';
        adc.delay6 = '0005';
        adc.CH0A_lines = [9,5,10,6,13,12,15,11,14,4,7,8];
        adc.CH0B_lines = [10,6,11,7,1,13,0,12,15,8,14,9];
    case 2
        
        adc.test_enable = '0008';
        adc.cal_idac = '007A';
        adc.cal_val_lo = '0083';
        adc.cal_val_hi = '0084';
        adc.cal_r_odd_hi = '0089';
        adc.cal_l_odd_hi = '008B';
        adc.cal_r_even_hi = '008D';
        adc.cal_l_even_hi = '008F';
        adc.cal_r_odd_lo = '008A';
        adc.cal_l_odd_lo = '008C';
        adc.cal_r_even_lo = '008E';
        adc.cal_l_even_lo = '0090';
        adc.mtha_idac = '0095';
        adc.ab_idac = '0096';
        adc.vref824_14 = '0044';
        adc.vref824_58 = '0098';
        adc.localBuff_12 = '0085';
        adc.localBuff_34 = '0086';
        adc.localBuff_56 = '0087';
        adc.localBuff_78 = '0088';
        adc.delay1 = '0008';
        adc.delay2 = '0009';
        adc.delay3 = '000A';
        adc.delay4 = '000B';
        adc.delay5 = '000C';
        adc.delay6 = '000D';
        adc.CH0A_lines = [2,15,8,12,3,11,4,1,7,14,5,13];
        adc.CH0B_lines = [13,14,12,15,2,9,1,8,5,11,4,10];
end

writeNi845x(ni845x, CS.RST, '0008', '0008');

[values, signal, aligned_values] = alignDataClocked(ni845x, LA, CS, adc, version);
% [values, signal] = alignData(ni845x, LA, CS, adc);
% alignBuffers(ni845x, powerSupply, multimeter, adc, CS, version);


% Free memory we're no longer using

closeNi845x(ni845x);

% fclose(powerSupply);
% fclose(multimeter);
% 
% delete(powerSupply);
% delete(multimeter);
delete(LA.hConnect)
load handel
sound(y,Fs)
% clear powerSupply;
% clear multimeter;