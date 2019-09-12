% Housekeeping
clear;
clc;
close all;

% open ni845x object to enable SPI communication
ni845x = openNi845x();
% reset the adc

% open variable power supply and precision multimeter
[powerSupply, multimeter] = openInstruments();

prompt = 'Enter ADC (1 or 2): ';
adc.num = input(prompt);
if adc.num ~= 1 && adc.num~=2
    adc.num = 1;
end
prompt = 'Enter the version number: ';
version = input(prompt,'s');
status = ['Running tests for ADC ', num2str(adc.num), '...'];
disp(status)

switch adc.num
    case 1
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
        adc.ab_idac = '0092';
    case 2
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
        adc.ab_idac = '0096';
end

adc.CS_RFIC = 4;
adc.CS_RST = 5;
midcode = '8888';
reset = '0000';
buff_disable = '0000';

samples = 3;

writeNi845x(ni845x, adc.CS_RST, '0008', '0008')
writeNi845x(ni845x, adc.CS_RFIC, adc.ab_idac, midcode);
writeNi845x(ni845x, adc.CS_RFIC, adc.cal_val_lo, reset);
writeNi845x(ni845x, adc.CS_RFIC, adc.cal_val_hi, reset);

buffer_defaults = zeros(4,16);

for i = 1:16
    buff_enable = dec2hex((2^16)/(2^i),4);
    for n = 1:4
        switch n
            case 1
                cal_r = adc.cal_r_odd_hi;
                cal_l = adc.cal_l_odd_hi;
                status = ['Clearing Odd High Buffer ', num2str(i), '.'];
                disp(status);
            case 2
                cal_r = adc.cal_r_odd_lo;
                cal_l = adc.cal_l_odd_lo;
                status = ['Clearing Odd Low Buffer ', num2str(i), '.'];
                disp(status);
            case 3
                cal_r = adc.cal_r_even_hi;
                cal_l = adc.cal_l_even_hi;
                status = ['Clearing Even High Buffer ', num2str(i), '.'];
                disp(status);
            case 4
                cal_r = adc.cal_r_even_lo;
                cal_l = adc.cal_l_even_lo;
                status = ['Clearing Even Low Buffer ', num2str(i), '.'];
                disp(status);
        end
        writeNi845x(ni845x, adc.CS_RFIC, cal_r, buff_enable);
        [v_offset_r,~] = calAVG(multimeter, samples);
        writeNi845x(ni845x, adc.CS_RFIC, cal_r, buff_disable);
        writeNi845x(ni845x, adc.CS_RFIC, cal_l, buff_enable);
        [v_offset_l,~] = calAVG(multimeter, samples);
        writeNi845x(ni845x, adc.CS_RFIC, cal_l, buff_disable);
        while (v_offset_r - v_offset_l) > 1e-5
            toggleBuffers(ni845x, adc.CS_RFIC, adc.cal_val_lo, adc.cal_val_hi,...
                reset, buff_enable, buff_disable, cal_r, cal_l);
            writeNi845x(ni845x, adc.CS_RFIC, cal_r, buff_enable);
            [v_offset_r,~] = calAVG(multimeter, samples);
            writeNi845x(ni845x, adc.CS_RFIC, cal_r, buff_disable);
            writeNi845x(ni845x, adc.CS_RFIC, cal_l, buff_enable);
            [v_offset_l,~] = calAVG(multimeter, samples);
            writeNi845x(ni845x, adc.CS_RFIC, cal_l, buff_disable);
        end
        buffer_defaults(n,i) = v_offset_r;
    end
end

calllib('ni845x_lib','ni845xSpiConfigurationClose', ni845x.SPIHandle);
calllib('ni845x_lib','ni845xClose', ni845x.DeviceHandle);
calllib('ni845x_lib','ni845xCloseFindDeviceHandle', ni845x.FirstDevice);

unloadlibrary ni845x_lib;

fclose(powerSupply);
fclose(multimeter);

clear ni845x;
delete(powerSupply);
clear powerSupply;
delete(multimeter);
clear multimeter;

first_part = 'C:\Users\testing\Desktop\ADC Testing 2019\';
folder = 'BufferCalibration - Simple\Excel Data\';
file_path = [first_part, folder];
d = date;

buff_str = [file_path, d,'adc', num2str(adc.num), 'buffer_defaults', 'v', version];
xls_str = [buff_str, '.xls'];
% mat_str = [buff_str, '.mat'];
xlswrite(xls_str, buffer_defaults);
% save(mat_str, 'buffer_defaults');
