function ni845x = openNi845x()

ni845x.ChipSelect = 0;
ni845x.ClockRate  = 10;

if not(libisloaded('ni845x_lib'))
    loadlibrary('C:\Windows\System32\ni845x.dll','C:\Program Files (x86)\National Instruments\NI-845x\MS Visual C\ni845x.h','alias','ni845x_lib')
end

[error, ni845x.FindDeviceHandle, ni845x.FirstDevice, ni845x.NumberFound] = calllib('ni845x_lib','ni845xFindDevice',blanks(260), 100, 100);
% libfunctions('ni845x','-full')
if error ~= 0
    disp('Error')
end

[error, ni845x.DeviceName, ni845x.DeviceHandle] = calllib('ni845x_lib','ni845xOpen', ni845x.FindDeviceHandle, 100);
if error ~= 0
    disp('Error')
end

calllib('ni845x_lib','ni845xSetIoVoltageLevel', ni845x.DeviceHandle, 18);

[error, ni845x.SPIHandle] = calllib('ni845x_lib','ni845xSpiConfigurationOpen', 100);
if error ~= 0
    disp('Error')
end

calllib('ni845x_lib','ni845xSpiConfigurationSetChipSelect', ni845x.SPIHandle, ni845x.ChipSelect);
calllib('ni845x_lib','ni845xSpiConfigurationSetClockRate', ni845x.SPIHandle, ni845x.ClockRate);
calllib('ni845x_lib','ni845xSpiConfigurationSetClockPolarity', ni845x.SPIHandle, 0);
calllib('ni845x_lib','ni845xSpiConfigurationSetClockPhase', ni845x.SPIHandle, 0);

end
