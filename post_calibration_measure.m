% Automatically calibrates ADC AB buffers for SPEAR ADC
% Jacob Orkis and John Hribar
% 6.10.2019

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
        adc.ab_idac = '0092';
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
        adc.ab_idac = '0096';
end

adc.CS_RFIC = 4;
adc.CS_RST = 5;
midcode = '8888';

writeNi845x(ni845x, adc.CS_RST, '0008', '0008')

voltages = [0:32]; % these are the numbers of the voltages buffers you want to test, default from 0 - 32
samples = 5; % three as default, up to 100 but will increase time exponentially
[voltages_info, abidac_info, min_idac] = calOutBiasdetailed(ni845x, adc, powerSupply, multimeter, voltages, samples);

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
folder = 'BufferCalibration - Gray\Excel Data\';
file_path = [first_part, folder];
d = date;

voltages_str = [file_path, d, 'adc', num2str(adc.num),...
    'detailedVoltages', 'v', version, '.xls'];
abidac_str = [file_path, d, 'adc', num2str(adc.num),...
    'detailedABIDAC', 'v', version, '.xls'];
warning('OFF','MATLAB:xlswrite:AddSheet');
for i = 1:length(voltages)
    voltage = 1 + voltages(i) * (.5/32);
    page = ['@', num2str(voltage), 'V'];
    writematrix(voltages_info(:,:,i),voltages_str,'Sheet',page);
    writematrix(abidac_info(:,:,i),abidac_str,'Sheet',page);
end
save('voltages_info.mat','voltages_info')