function [CH0A, CH0B, first_12_top, first_12_bot,...
    is_aligned, is_identified] = first12Adjust(ni845x, LA, CS, cycle)

is_aligned = false;
is_identified = false;

switch CS
    case 0
        rc_str = 'RC0A';
    case 1
        rc_str = 'RC0B';
    case 2
        rc_str = 'RC1B';
    case 3
        rc_str = 'RC1A';
end

i_init = hex2dec(readNi845x(ni845x, CS, '0010'));
j_init = hex2dec(readNi845x(ni845x, CS, '0012'));
k_init = hex2dec(readNi845x(ni845x, CS, '0011'));

if i_init == 0 && j_init == 0 && k_init == 0
    i_init = 3;
    j_init = 3;
    k_init = 3;
end

for i = i_init:-1:0
    writeNi845x(ni845x, CS, '0010', dec2hex(i,4));
    for j = j_init:-1:0
        writeNi845x(ni845x, CS, '0012', dec2hex(j,4));
        for k = k_init:-1:0
            writeNi845x(ni845x, CS, '0011', dec2hex(k,4));
            [CH0A, CH0B] = update(LA, true);
            pause(2);
            status = [dec2hex(i,4), ' to 0010 on ', rc_str, '.'];
            disp(status);
            status = [dec2hex(k,4), ' to 0011 on ', rc_str, '.'];
            disp(status);
            status = [dec2hex(j,4), ' to 0012 on ', rc_str, '.'];
            disp(status);
            first_12_top = first12(CH0A.vec, cycle);
            first_12_bot = first12(CH0B.vec, cycle);
            switch CS
                case 0
                    first_12 = first_12_top;
                case 1
                    first_12 = first_12_bot;
                case 2
                    first_12 = first_12_bot;
                case 3
                    first_12 = first_12_top;
            end
            if first_12 ~= 0
                is_aligned = true;
                is_identified = false;
                break;
            end
        end
        if is_aligned
            break;
        end
    end
    if is_aligned
        break;
    end
end
