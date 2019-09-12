function delta_min = calLocalHiLo_AB(ni845x, multimeter, samples, adc,...
    delta_odd, delta_even, delta_hi, delta_lo, delta_min)

CS_RFIC = 4;
reset = '0000';
buff_disable = '0000';

for i = 0:3
    switch i
        case 0
            address = adc.localBuff_12;
        case 1
            address = adc.localBuff_34;
        case 2
            address = adc.localBuff_56;
        case 3
            address = adc.localBuff_78;
    end
    for j = 1:4:5
        if j == 1
            adc_offset = 8;
            subadc = 2*i + 1;
            delta_mid = delta_odd;
        else
            adc_offset = 0;
            subadc = 2*i + 2;
            delta_mid = delta_even;
        end
        subadc = num2str(subadc);
        for k = 0:3
            if k == 0
                vref = delta_hi;
                buff = 1.5;
                status = ['Calibrating VREFHI for subadc ', subadc];
            elseif k > 0 && k < 3
                vref = delta_lo;
                buff = 1.0;
                status = ['Calibrating VREFLO for subadc ', subadc];
            else
                vref = delta_mid;
                buff = 1.25;
                status = ['Calibrating VCM for subadc ', subadc];
            end
            disp(status);
            enableR = dec2hex(2^(k+4+adc_offset), 4);
            enableL = dec2hex(2^(k+adc_offset), 4);
            writeNi845x(ni845x, CS_RFIC, adc.cal_val_lo, reset);
            writeNi845x(ni845x, CS_RFIC, adc.cal_val_hi, reset);
            writeNi845x(ni845x, CS_RFIC, address, enableR);
            writeNi845x(ni845x, CS_RFIC, address, buff_disable);
            writeNi845x(ni845x, CS_RFIC, address, enableL);
            writeNi845x(ni845x, CS_RFIC, address, buff_disable);
            writeNi845x(ni845x, CS_RFIC, address, enableR);
            writeNi845x(ni845x, CS_RFIC, adc.cal_val_lo, '8000');
            pause(0.1)
            [diff, ~] = calAVG(multimeter, samples);
            delta_r = diff - vref;
            writeNi845x(ni845x, CS_RFIC, adc.cal_val_lo, reset);
            writeNi845x(ni845x, CS_RFIC, address, buff_disable);
            writeNi845x(ni845x, CS_RFIC, address, enableL);
            writeNi845x(ni845x, CS_RFIC, adc.cal_val_lo, '8000');
            pause(0.1)
            [diff, ~] = calAVG(multimeter, samples);
            delta_l = diff - vref;
            writeNi845x(ni845x, CS_RFIC, adc.cal_val_lo, reset);
            writeNi845x(ni845x, CS_RFIC, address, buff_disable);
            adjust = j + k + i*8;
            if abs(delta_r) < abs(delta_l)
                [delta_min(1, adjust), delta_min(3, adjust),delta_min(4, adjust),...
                    delta_min(5, adjust)] = calBuff(address, enableR,...
                    vref, ni845x, multimeter, samples, adc.cal_val_lo);
                delta_min(2, adjust) = 0;
                delta_min(6, adjust) = buff;
            else
                [delta_min(1, adjust), delta_min(3, adjust),delta_min(4, adjust),...
                    delta_min(5, adjust)] = calBuff(address, enableL,...
                    vref, ni845x, multimeter, samples, adc.cal_val_lo);
                delta_min(2, adjust) = 1;
                delta_min(6, adjust) = buff;
            end
        end
    end
end
end