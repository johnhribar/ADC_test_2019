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
[powerSupply, multimeter] = openInstruments();
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
end

samples = 3;
measured_offsets = zeros(6,32,6);
load('voltages_info.mat');
load('buffer_offsets.mat');

for i = 1:6
    switch i
        case 1
            buff_size = 1;
            buff = delta_min_vrefhi;
        case 2
            buff_size = 1;
            buff = delta_min_vreflo;
        case 3
            buff_size = 31;
            buff = delta_min_even;
        case 4
            buff_size = 31;
            buff = delta_min_odd;
        case 5
            buff_size = 16;
            buff = delta_min_vref;
        case 6
            buff_size = 32;
            buff = delta_min_local;
    end
    for j = 1:buff_size
        address = buff(2,j);
        data = dec2hex(buff(3,j));
        if buff_size == 1
            buff_enable = '8000';
        elseif j < 16
            buff_enable = dec2hex((2^15)/(2^j),4);
        else
            buff_enable = dec2hex((2^16)/(2^j-15),4);
        end
        writeNi845x(ni845x, CS.RFIC, address, buff_enable);
        writeNi845x(ni845x, CS.RFIC, adc.cal_val_lo, data);
        [measured_offsets(1,j,i), ~] = calAVG(multimeter, samples);
        measured_offsets(2,j,i) = address;
        measured_offsets(3,j,i) = data;
        [measured_offsets(4,j,i), ~, measured_offsets(5,j,i), ~] = calAvgVolt(multimeter,samples);
        measured_offsets(6,j,i) = measured_offsets(4,j,i) - measured_offsets(5,j,i);
    end
end
save('measured_offsets.mat', 'measured_offsets');