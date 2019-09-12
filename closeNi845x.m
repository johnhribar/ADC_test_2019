function closeNi845x(ni845x)

calllib('ni845x_lib','ni845xSpiConfigurationClose', ni845x.SPIHandle);
calllib('ni845x_lib','ni845xClose', ni845x.DeviceHandle);
% calllib('ni845x_lib','ni845xCloseFindDeviceHandle', ni845x.FirstDevice);

unloadlibrary ni845x_lib;

% delete('ni845x');
% clear ni845x;

end