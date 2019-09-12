function voltages_info = calOutBias(ni845x, powerSupply, multimeter, voltages, samples)
% Turns on the test voltage, finds the normal operating voltage for that
% buffer, then adjust the IDAC to get the smallest delta
CS_RFIC = 4;

prompt = 'Enter multimeter value for VREFHI from board: ';
vrefhi = input(prompt);
prompt = 'Enter multimeter value for VREFL0 from board: ';
vreflo = input(prompt);
vrefdelta = vrefhi - vreflo;

fprintf(powerSupply, '%c\n', 'OUTPut ON');
% Enable test mode for the buffers

writeNi845x(ni845x, CS_RFIC, '0042', '000C');

% Applies appropriate external voltage to buffer and reads the offset
voltages_info = ones(4,length(voltages));
for i = 1:length(voltages)
    voltage = vreflo + voltages(i) * (vrefdelta/32);
    voltages_info(1, i) = voltage;
    status = ['Calibrating for ', num2str(voltage), ' V'];
    disp(status)
    volt_command = sprintf('VOLTage %f', voltage);
    fprintf(powerSupply, '%c\n', volt_command);
    pause(2);
    [vref, ~, vout, ~] = calAvgVolt(multimeter, samples);
    voltages_info(2, i) = vref;
    voltages_info(3, i) = vout;
    [delta, ~] = calAVG(multimeter, samples);
    voltages_info(4, i) = delta;
end
fprintf(powerSupply, '%c\n', 'OUTPut OFF');
% Take buffer out of test mode
writeNi845x(ni845x, CS_RFIC, '0042', '0000');