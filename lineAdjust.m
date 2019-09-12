function [CH0A, CH0B, first_12_top, first_12_bot] = lineAdjust(ni845x, LA, ordered_offset, CS, adc)

if adc.num == 1
    CSA = CS.RC0A;
    CSB = CS.RC0B;
else
    CSA = CS.RC1A;
    CSB = CS.RC1B;
end

CH0A_offset = ordered_offset(1,:);
CH0B_offset = ordered_offset(2,:);

address_adjust = 0;
for i = 1:length(CH0A_offset)
    data0A = 5*CH0A_offset(i)-1;
    data0B = 5*CH0B_offset(i)-1;
    if data0A == 19
        data0A = 15;
    end
    if data0B == 19
        data0B = 15;
    end
    if data0A > 15 || data0B > 15
        error('Offset exceeds range')
    end
    address = 80;
    address = address + address_adjust;
    address = dec2hex(address, 4);
    if data0A > 0
        data0A = dec2hex(data0A, 4);
        status = ['Writing ', data0A, ' to ', address, ' on RC0A...'];
        disp(status)
        writeNi845x(ni845x, CSA, address, data0A);
    end
    if data0B > 0
        data0B = dec2hex(data0B, 4);
        status = ['Writing ', data0B, ' to ', address, ' on RC0B...'];
        disp(status)
        writeNi845x(ni845x, CSB, address, data0B);
    end
    if address_adjust == 3 || address_adjust == 9 
        address_adjust = address_adjust + 3;
    else
        address_adjust = address_adjust + 1;
    end
end

[CH0A, CH0B] = update(LA, true);

first_12_top = first12(CH0A.vec, adc.cycle);
first_12_bot = first12(CH0B.vec, adc.cycle);