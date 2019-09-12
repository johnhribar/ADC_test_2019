function writeNi845x(ni845x, ChipSelect, Address, Data)

ResetPin = 5;
num_tries = 20;
ni845x.ChipSelect = ChipSelect;
address = hex2dec(Address);
data = hex2dec(Data);
WriteSize = uint8(4);
WriteData = uint8(zeros(1,4));

WriteData(1) = hex2dec('40');
WriteData(2) = bitand(address,hex2dec('00FF'));
WriteData(3) = bitshift(data,-8);
WriteData(4) = bitand(data,hex2dec('00FF'));

ReadData = readNi845x(ni845x, ChipSelect, Address);

% calllib('ni845x_lib','ni845xSpiConfigurationSetChipSelect', ni845x.SPIHandle, ni845x.ChipSelect);
%     [~, ~, ~, ~] = calllib('ni845x_lib','ni845xSpiWriteRead',...
%         ni845x.DeviceHandle, ni845x.SPIHandle, WriteSize, WriteData, 100, 100);
count = 0;
if ChipSelect ~= ResetPin
    while ~strcmp(Data, ReadData) && count < num_tries

        calllib('ni845x_lib','ni845xSpiConfigurationSetChipSelect', ni845x.SPIHandle, ni845x.ChipSelect);
        [~, ~, ~, ~] = calllib('ni845x_lib','ni845xSpiWriteRead',...
            ni845x.DeviceHandle, ni845x.SPIHandle, WriteSize, WriteData, 100, 100);

        ReadData = readNi845x(ni845x, ChipSelect, Address);
        count = count + 1;

    end
else
    calllib('ni845x_lib','ni845xSpiConfigurationSetChipSelect', ni845x.SPIHandle, ni845x.ChipSelect);
    [~, ~, ~, ~] = calllib('ni845x_lib','ni845xSpiWriteRead',...
        ni845x.DeviceHandle, ni845x.SPIHandle, WriteSize, WriteData, 100, 100);
end

try_again = true;

while count == num_tries && try_again == true
    status = ['Warning: Cannot write ', Data, ' to address ', Address, ' on CS ', num2str(ChipSelect), '...',...
        newline, 'Instead ', ReadData, ' is written...'];
    warning(status)
    status = ['1. Try to rewrite original value', newline, '2. Leave written value',...
        newline, '3. Try to write new value'];
    disp(status);
    prompt = 'Choose an option: ';
    response = input(prompt);
    switch response
        case 1
            count = 0;
            while ~strcmp(Data, ReadData) && count < num_tries
                
                calllib('ni845x_lib','ni845xSpiConfigurationSetChipSelect', ni845x.SPIHandle, ni845x.ChipSelect);
                [~, ~, ~, ~] = calllib('ni845x_lib','ni845xSpiWriteRead',...
                    ni845x.DeviceHandle, ni845x.SPIHandle, WriteSize, WriteData, 100, 100);
                
                ReadData = readNi845x(ni845x, ChipSelect, Address);
                count = count + 1;
                
            end
        case 2
            try_again = false;
        case 3
            count = 0;
            prompt = 'Enter value to write in hex: ';
            Data = input(prompt, 's');
            data = hex2dec(Data);
            WriteData(3) = bitshift(data,-8);
            WriteData(4) = bitand(data,hex2dec('00FF'));
            while ~strcmp(Data, ReadData) && count < num_tries
                
                calllib('ni845x_lib','ni845xSpiConfigurationSetChipSelect', ni845x.SPIHandle, ni845x.ChipSelect);
                [~, ~, ~, ~] = calllib('ni845x_lib','ni845xSpiWriteRead',...
                    ni845x.DeviceHandle, ni845x.SPIHandle, WriteSize, WriteData, 100, 100);
                
                ReadData = readNi845x(ni845x, ChipSelect, Address);
                count = count + 1;
                
            end
    end
end