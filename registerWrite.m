function registerWrite(ni845x, file_str, adc_str)

first_part = 'C:\Users\testing\Desktop\ADC Testing 2019\';
folder = 'Combined\ConfigurationFiles\';
file_name = [first_part, folder, file_str];
CS_RC0A = 0;
CS_RC0B = 1;
CS_RC1B = 2;
CS_RC1A = 3;
CS_RFIC = 4;
config_file = readtable(file_name, 'Format', '%s%s');

if strcmp('ADC', adc_str)
    for i = 1:size(config_file,1)
        writeNi845x(ni845x, CS_RFIC, config_file.Address(i), config_file.Value(i));
    end
elseif strcmp('RCASIC', adc_str)
    for i = 1:size(config_file,1)
        writeNi845x(ni845x, CS_RC0A, config_file.Address(i), config_file.Value(i));
        writeNi845x(ni845x, CS_RC0B, config_file.Address(i), config_file.Value(i));
        writeNi845x(ni845x, CS_RC1A, config_file.Address(i), config_file.Value(i));
        writeNi845x(ni845x, CS_RC1B, config_file.Address(i), config_file.Value(i));
    end
end