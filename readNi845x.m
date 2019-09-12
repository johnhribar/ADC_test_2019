function readData = readNi845x(ni845x, ChipSelect, Address)

ni845x.ChipSelect = ChipSelect;
address = hex2dec(Address);
NumberToRead = uint8(4);
WriteSize = uint8(4);
WriteData = uint8(zeros(1,4));
DataOut = uint8(zeros(1,NumberToRead));

WriteData(1) = hex2dec('C0');
WriteData(2) = bitand(address,hex2dec('00FF'));

calllib('ni845x_lib','ni845xSpiConfigurationSetChipSelect', ni845x.SPIHandle, ni845x.ChipSelect);
[~, ~, ~, DataOut]=calllib('ni845x_lib','ni845xSpiWriteRead',...
    ni845x.DeviceHandle, ni845x.SPIHandle, WriteSize, WriteData, 100, DataOut);

readData = double(DataOut(3))*2^8 + double(DataOut(4));
readData = dec2hex(readData, 4);