function [delta_min, cal_val, vref, vout] = calBuff(buffer, buff_enable,...
    delta_ideal, ni845x, multimeter, samples, cal_val_lo)

CS_RFIC = 4;
buff_disable = '0000';

writeNi845x(ni845x, CS_RFIC, buffer, buff_enable);
[diff, ~] = calAVG(multimeter, samples);
delta_min = diff - delta_ideal;
offset = 0;
test_delta = 1;
test_offset = 0;
for n = 15:-1:2
    cal_val = 2^n + offset;
    cal_val = dec2hex(cal_val, 4);
    writeNi845x(ni845x, CS_RFIC, cal_val_lo, cal_val);
    [diff, ~] = calAVG(multimeter, samples);
    delta = diff - delta_ideal;
    if abs(delta) < abs(delta_min)
        if (delta_min < 0 && delta < 0) || (delta_min > 0 && delta > 0)
            delta_min = delta;
            offset = offset + 2^n;
        else
            test_delta = delta;
            test_offset = 2^n;
            break;
        end
    else
        break;
    end
end
best_value = dec2hex(offset, 4);
for n = 1:3
    cal_val = n + offset;
    cal_val = dec2hex(cal_val, 4);
    writeNi845x(ni845x, CS_RFIC, cal_val_lo, cal_val);
    [diff, ~] = calAVG(multimeter, samples);
    delta = diff - delta_ideal;
    if abs(delta) < abs(delta_min)
        delta_min = delta;
        best_value = cal_val;
    else
        break;
    end
    if n == 3 && abs(delta_min) > abs(test_delta)
        best_value = dec2hex((offset + test_offset), 4);
        delta_min = test_delta;
    end
end
if abs(delta_min) > 1e-2
    [bad_data1, ~, bad_data2, ~] = calAvgVolt(multimeter, samples);
    status = ['The ideal delta from this buffer is ', num2str(delta_ideal)...
        newline,'The minimum delta for this buffer is ', num2str(delta_min),...
        newline, ' The voltage level on channel 1 is ', num2str(bad_data1),...
        newline, ' The voltage level on channel 2 is ', num2str(bad_data2)];
    disp(status);
    prompt = '. Do you wish to continue (Y or N)';
    response = lower(input(prompt,'s'));
    if response(1) ~= 'y'
        error('Figure out what the heck is going on. MATLAB out.')
    end
end
writeNi845x(ni845x, CS_RFIC, cal_val_lo, best_value);
cal_val = hex2dec(best_value);
[vref, ~, vout, ~] = calAvgVolt(multimeter,samples);
%vout = str2double(query(multimeter, 'MEASure:VOLTage:DC? AUTO, MAX, (@FRONt2)'));
writeNi845x(ni845x, CS_RFIC, buffer, buff_disable);
writeNi845x(ni845x, CS_RFIC, cal_val_lo, buff_disable);
end