clear;
clc;
close all;

% open ni845x object to enable SPI communication
ni845x = openNi845x();
RC0A = 0;
RC0B = 1;
RC1B = 2;
RC1A = 3;
RFIC = 4;
RST = 5;

CS = RC1B;

if CS == 4
    registers = 153;
elseif CS == 5
    error('Cannot read reset chip');
else
    registers = 101;
end

addresses = zeros(1,registers + 1);
values = zeros(1,registers + 1);
for address = 0:registers
    values(address+1) = hex2dec(readNi845x(ni845x,CS,dec2hex(address, 4)));
    addresses(address + 1) = address;
end

closeNi845x(ni845x);

addresses_hex = string(dec2hex(addresses, 4));
values_hex = string(dec2hex(values, 4));
combined = [addresses_hex,values_hex];