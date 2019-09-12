function registerWriteGui(ni845x, file_name, cs)

config_file = readtable(file_name, 'Format', '%s%s');

for i = 1:size(config_file,1)
    writeNi845x(ni845x, cs, config_file.Address(i), config_file.Value(i));
end