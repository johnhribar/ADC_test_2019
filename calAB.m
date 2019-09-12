function delta_min = calAB(ni845x, multimeter, samples, cal_val_lo, cal_val_hi, ...
    cal_r, cal_l,ideal_deltas, delta_min, buff_size, start, even)

CS_RFIC = 4;
reset = '0000';
buff_disable = '0000';
start = start + 1;

for i = 1:buff_size
    switch buff_size
        case 15
            buff_enable = dec2hex((2^15)/(2^i),4);
            delta_ideal = ideal_deltas(33-i);
            if even
                status = ['Beginning even buffer ', num2str(start-i)];
            else
                status = ['Beginning odd buffer ', num2str(start-i)];
            end
        case 16
            buff_enable = dec2hex((2^16)/(2^i),4);
            delta_ideal = ideal_deltas(18-i);
            if even
                status = ['Beginning even buffer ', num2str(start-i)];
            else
                status = ['Beginning odd buffer ', num2str(start-i)];
            end
        case 1
            buff_enable = '8000';
            if even
                delta_ideal = ideal_deltas(1);
                status = 'Beginning buffer VREFLO';
            else
                delta_ideal = ideal_deltas(33);
                status = 'Beginning buffer VREFHI';
            end
    end
    disp(status);
    toggleBuffers(ni845x, CS_RFIC, cal_val_lo, cal_val_hi, reset, buff_enable, buff_disable,...
        cal_r, cal_l)
    writeNi845x(ni845x, CS_RFIC, cal_r, buff_enable);
    writeNi845x(ni845x, CS_RFIC, cal_val_lo, '8000');
    pause(0.1)
    [diff, ~] = calAVG(multimeter, samples);
    delta_r = diff - delta_ideal;
    writeNi845x(ni845x, CS_RFIC, cal_val_lo, reset);
    writeNi845x(ni845x, CS_RFIC, cal_r, buff_disable);
    writeNi845x(ni845x, CS_RFIC, cal_l, buff_enable);
    writeNi845x(ni845x, CS_RFIC, cal_val_lo, '8000');
    pause(0.1)
    [diff, ~] = calAVG(multimeter, samples);
    delta_l = diff - delta_ideal;
    writeNi845x(ni845x, CS_RFIC, cal_val_lo, reset);
    writeNi845x(ni845x, CS_RFIC, cal_l, buff_disable);
    if abs(delta_r) < abs(delta_l)
        [delta_min(1, start-i), delta_min(3, start-i),delta_min(4, start-i),...
            delta_min(5, start-i)] = calBuff(cal_r, buff_enable,...
            delta_ideal, ni845x, multimeter, samples, cal_val_lo);
        delta_min(2, start-i) = hex2dec(cal_r);
    else
        [delta_min(1, start-i), delta_min(3, start-i),delta_min(4, start-i),...
            delta_min(5, start-i)] = calBuff(cal_l, buff_enable,...
            delta_ideal, ni845x, multimeter, samples, cal_val_lo);
        delta_min(2, start-i) = hex2dec(cal_l);
    end
    delta_min(6, start-i) = delta_min(4, start-i) - delta_min(5, start-i);
end
end