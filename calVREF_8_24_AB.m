function delta_min = calVREF_8_24_AB(ni845x, multimeter, samples, cal_val_lo, cal_val_hi, ...
    vref824_14, vref824_58, ideal_deltas_odd, ideal_deltas_even, delta_min)

CS_RFIC = 4;
reset = '0000';
buff_disable = '0000';
adc_num = 1;
 
count = 0;
for j = 1:2
    if j == 1
        address = vref824_14;
        write_offset = 1;
    else
        address =  vref824_58;
        write_offset = 9;
    end
    for i = 0:2:14
        enableR = dec2hex((2^i), 4);
        enableL = dec2hex((2^(i+1)), 4);
        if mod(adc_num, 2) == 0
            vref_8 = ideal_deltas_even(8);
            vref_24 = ideal_deltas_even(24);
        else
            vref_8 = ideal_deltas_odd(8);
            vref_24 = ideal_deltas_odd(24);
        end
        if mod(i,4) == 0
            vref = vref_8;
            count = count + 1;
            status = ['Calibrating VREF8 buffer for sub adc ', num2str(count)];
            disp(status);
        else
            vref = vref_24;
            status = ['Calibrating VREF24 buffer for sub adc ', num2str(count)];
            disp(status);
            adc_num = adc_num + 1;
        end
        writeNi845x(ni845x, CS_RFIC, cal_val_lo, reset);
        writeNi845x(ni845x, CS_RFIC, cal_val_hi, reset);
        writeNi845x(ni845x, CS_RFIC, address, enableR);
        writeNi845x(ni845x, CS_RFIC, address, buff_disable);
        writeNi845x(ni845x, CS_RFIC, address, enableL);
        writeNi845x(ni845x, CS_RFIC, address, buff_disable);
        writeNi845x(ni845x, CS_RFIC, address, enableR);
        writeNi845x(ni845x, CS_RFIC, cal_val_lo, '8000');
        pause(0.1)
        [diff, ~] = calAVG(multimeter, samples);
        delta_r = diff - vref;
        writeNi845x(ni845x, CS_RFIC, cal_val_lo, reset);
        writeNi845x(ni845x, CS_RFIC, address, buff_disable);
        writeNi845x(ni845x, CS_RFIC, address, enableL);
        writeNi845x(ni845x, CS_RFIC, cal_val_lo, '8000');
        pause(0.1)
        [diff, ~] = calAVG(multimeter, samples);
        delta_l = diff - vref;
        writeNi845x(ni845x, CS_RFIC, cal_val_lo, reset);
        writeNi845x(ni845x, CS_RFIC, address, buff_disable);
        adjust = write_offset + (i / 2);
        if abs(delta_r) < abs(delta_l)
            [delta_min(1, adjust), delta_min(3, adjust),delta_min(4, adjust),...
                delta_min(5, adjust)] = calBuff(address, enableR,...
                vref, ni845x, multimeter, samples, cal_val_lo);
            delta_min(2, adjust) = 0;
        else
            [delta_min(1, adjust), delta_min(3, adjust),delta_min(4, adjust),...
                delta_min(5, adjust)] = calBuff(address, enableL,...
                vref, ni845x, multimeter, samples, cal_val_lo);
            delta_min(2, adjust) = 1;
        end
    end
end
end