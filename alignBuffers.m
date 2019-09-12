function alignBuffers(ni845x, powerSupply, multimeter, adc, CS, version)

midcode = '8888';
writeNi845x(ni845x, CS.RFIC, adc.mtha_idac, midcode);
writeNi845x(ni845x, CS.RFIC, adc.ab_idac, midcode);

voltages = 0:32; % these are the numbers of the voltages buffers you want to test, default from 0 - 32
samples = 3; % three as default, up to 100 but will increase time exponentially
voltages_info = calOutBias(ni845x, powerSupply, multimeter, voltages, samples);
% load('voltages_info.mat','voltages_info');
save('voltages_info.mat','voltages_info');

% disp(voltages_info);

delta_min_odd = zeros(6,31);
delta_min_even = zeros(6,31);
delta_min_vrefhi = zeros(6,1);
delta_min_vreflo = zeros(6,1);
delta_min_vref = zeros(5,16);
delta_min_local = zeros(6,32);
% load('buffer_offsets.mat', 'delta_min_even', 'delta_min_odd', 'delta_min_vrefhi', 'delta_min_vreflo');

delta_min_vrefhi = calAB(ni845x, multimeter, samples, adc.cal_val_lo, adc.cal_val_hi,...
    adc.cal_r_odd_hi, adc.cal_l_odd_hi, voltages_info(4,:), delta_min_vrefhi, 1, 1, 0);

delta_min_vreflo = calAB(ni845x, multimeter, samples, adc.cal_val_lo, adc.cal_val_hi,...
    adc.cal_r_even_hi, adc.cal_l_even_hi, voltages_info(4,:), delta_min_vreflo, 1, 1, 1);

delta_min_odd = calAB(ni845x, multimeter, samples, adc.cal_val_lo, adc.cal_val_hi,...
    adc.cal_r_odd_hi, adc.cal_l_odd_hi, voltages_info(4,:), delta_min_odd, 15, 31, 0);

delta_min_odd = calAB(ni845x, multimeter, samples, adc.cal_val_lo, adc.cal_val_hi,...
    adc.cal_r_odd_lo, adc.cal_l_odd_lo, voltages_info(4,:), delta_min_odd, 16, 16, 0);

delta_min_even = calAB(ni845x, multimeter, samples, adc.cal_val_lo, adc.cal_val_hi,...
    adc.cal_r_even_hi, adc.cal_l_even_hi, voltages_info(4,:), delta_min_even, 15, 31, 1);

delta_min_even = calAB(ni845x, multimeter, samples, adc.cal_val_lo, adc.cal_val_hi,...
    adc.cal_r_even_lo, adc.cal_l_even_lo, voltages_info(4,:), delta_min_even, 16, 16, 1);

delta_min_local = calLocalHiLo_AB(ni845x, multimeter, samples, adc, delta_min_odd(6,16),...
    delta_min_even(6,16), delta_min_vrefhi(6), delta_min_vreflo(6), delta_min_local);

delta_min_vref = calVREF_8_24_AB(ni845x, multimeter, samples, adc.cal_val_lo, adc.cal_val_hi,...
    adc.vref824_14, adc.vref824_58, delta_min_odd(6,:), delta_min_even(6,:), delta_min_vref);

first_part = 'C:\Users\testing\Desktop\ADC Testing 2019\';
folder = 'Combined\Excel Data\';
file_path = [first_part, folder];

voltages_str = [file_path, version, 'adc', num2str(adc.num), 'voltages.xls'];
offsets_str = [file_path, version, 'adc', num2str(adc.num), 'offsets.xls'];
local_offsets_str = [file_path, version, 'adc', num2str(adc.num), 'local_offsets.xls'];

writematrix(voltages_info, voltages_str);
writematrix(delta_min_vreflo, offsets_str, 'Range', 'A2:A7')
writematrix(delta_min_even, offsets_str, 'Range', 'B2:AF7')
writematrix(delta_min_vrefhi, offsets_str, 'Range', 'AG9:AG14')
writematrix(delta_min_odd, offsets_str, 'Range', 'B9:AF14')
writematrix(delta_min_vref, local_offsets_str, 'Range', 'A2:P6')
writematrix(delta_min_local, local_offsets_str, 'Range', 'A8:AF13')

save('buffer_offsets.mat', 'delta_min_even', 'delta_min_odd', 'delta_min_vrefhi', 'delta_min_vreflo', 'delta_min_vref', 'delta_min_local')