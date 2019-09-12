function buffer_defaults = clearBuffers(adc, ni845x, multimeter, version)

midcode = '8888';
reset = '0000';
buff_disable = '0000';

writeNi845x(ni845x, adc.CS_RST, '0008', '0008')
writeNi845x(ni845x, adc.CS_RFIC, ab_idac, midcode);

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
        writeNi845x(ni845x, CS_RFIC, cal_r, buff_enable);
        [v_offset_r,~] = calAVG(multimeter);
        writeNi845x(ni845x, CS_RFIC, cal_r, buff_disable);
        writeNi845x(ni845x, CS_RFIC, cal_l, buff_enable);
        [v_offset_l,~] = calAVG(multimeter);
        writeNi845x(ni845x, CS_RFIC, cal_l, buff_disable);
        while (v_offset_r - v_offset_l) > 1e-5
            toggleBuffers(ni845x, CS_RFIC, cal_val_lo, cal_val_hi, reset, buff_enable, buff_disable,...
                cal_r, cal_l);
            writeNi845x(ni845x, CS_RFIC, cal_r, buff_enable);
            [v_offset_r,~] = calAVG(multimeter);
            writeNi845x(ni845x, CS_RFIC, cal_r, buff_disable);
            writeNi845x(ni845x, CS_RFIC, cal_l, buff_enable);
            [v_offset_l,~] = calAVG(multimeter);
            writeNi845x(ni845x, CS_RFIC, cal_l, buff_disable);
        end
        buffer_defaults(n,i) = v_offset_r;
    end
end

first_part = 'C:\Users\testing\Desktop\ADC Testing 2019\';
folder = 'BufferCalibration - Gray\Excel Data\';
file_path = [first_part, folder];
d = date;

buff_str = [file_path, d,'adc', num2str(adc), 'buffer_defaults', 'v', version];
xls_str = [buff_str, '.xls'];
% mat_str = [buff_str, '.mat'];
xlswrite(xls_str, buffer_defaults);
% save(mat_str, 'buffer_defaults');
