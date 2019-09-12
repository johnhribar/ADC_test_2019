function toggleBuffers(ni845x, CS, cal_val_lo, cal_val_hi, reset, buff_enable, buff_disable,...
    cal_r, cal_l)
% Switches opposite buffers off and on to normalize the voltage on the line
writeNi845x(ni845x, CS, cal_val_lo, reset);
writeNi845x(ni845x, CS, cal_val_hi, reset);
writeNi845x(ni845x, CS, cal_r, buff_enable);
writeNi845x(ni845x, CS, cal_r, buff_disable);
writeNi845x(ni845x, CS, cal_l, buff_enable);
writeNi845x(ni845x, CS, cal_l, buff_disable);