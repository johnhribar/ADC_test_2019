function [CH0A, CH0B] = finalAdjust(ni845x, CS, LA, line_offset, line_offset_adj, adc)

if adc == 1
    CSA = CS.RC0A;
    CSB = CS.RC0B;
else
    CSA = CS.RC1A;
    CSB = CS.RC1B;
end

for i = 1:2
    address_adjust = 0;
    if i == 1
        cs = CSA;
    else
        cs = CSB;
    end
    for j = 1:12        
        if line_offset_adj.plus_minus(i,j) == 0
            break;
        end
        address = 80 + address_adjust;
        address = dec2hex(address, 4);
        data = hex2dec(readNi845x(ni845x, cs, address));
        if line_offset_adj.plus_minus(i,j) >= line_offset.plus_minus(i,j) && data < 15
            data = data + 1;
            switch data
                case 5
                    data = 6;
                case 10
                    data = 12;
                case 11
                    data = 12;
                case 13
                    data = 14;
            end
        elseif line_offset_adj.plus_minus(i,j) < line_offset.plus_minus(i,j) && data > 0
            data = data - 1;
            switch data
                case 5
                    data = 4;
                case 10
                    data = 9;
                case 11
                    data = 9;
                case 13
                    data = 12;
            end
        end
        data_hex = dec2hex(data, 4);
        writeNi845x(ni845x, cs, address, data_hex);
        if address_adjust == 3 || address_adjust == 9
            address_adjust = address_adjust + 3;
        else
            address_adjust = address_adjust + 1;
        end
    end
end
[CH0A, CH0B] = update(LA, true);