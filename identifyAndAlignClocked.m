function [adc_odds, adc_evens, first_12_top, first_12_bot,...
    CH_A, CH_B, aligned_values] = identifyAndAlignClocked(ni845x, LA, CS, adc, version)

if adc.num == 1
    CS_A = CS.RC0A;
    CS_B = CS.RC0B;
else
    CS_A = CS.RC1A;
    CS_B = CS.RC1B;
end
% good_values = getGood(ni845x, LA, CS, adc, version);
load('10-Sep-2019_V7goodValues.mat','good_values');
totals = transpose(squeeze(sum(good_values)));
[channel_number, channel_position] = find(~totals);
channel_length = zeros(1,6);
channel_index = zeros(1,6);
if channel_position(1) == 1
    status = ['Unable to find a correct value for channel ', num2str(channel_number(1)),'_'];
    error(status);
else
    channel_start = channel_number(1);
    status = ['Starting on channel ', num2str(channel_start)];
    disp(status);
    for i = 1:6
        occurance = find(channel_number==i);
        channel_length(i) = channel_position(occurance(1));
    end
end
values_found = 0;
next_start = false;
for n = 1:channel_length(channel_start)
    if n == channel_length(channel_start)
        error('Cannot find shit');
    end
    if values_found == 5
        aligned_values(1,1) = convertCharsToStrings(readNi845x(ni845x,CS.RFIC,adc.delay1));
        aligned_values(2,1) = convertCharsToStrings(readNi845x(ni845x,CS.RFIC,adc.delay2));
        aligned_values(3,1) = convertCharsToStrings(readNi845x(ni845x,CS.RFIC,adc.delay3));
        aligned_values(4,1) = convertCharsToStrings(readNi845x(ni845x,CS.RFIC,adc.delay4));
        aligned_values(5,1) = convertCharsToStrings(readNi845x(ni845x,CS.RFIC,adc.delay5));
        aligned_values(6,1) = convertCharsToStrings(readNi845x(ni845x,CS.RFIC,adc.delay6));
        aligned_values(7,1) = convertCharsToStrings(readNi845x(ni845x,CS_A,'0010'));
        aligned_values(8,1) = convertCharsToStrings(readNi845x(ni845x,CS_A,'0011'));
        aligned_values(9,1) = convertCharsToStrings(readNi845x(ni845x,CS_A,'0012'));
        aligned_values(10,1) = convertCharsToStrings(readNi845x(ni845x,CS_B,'0010'));
        aligned_values(11,1) = convertCharsToStrings(readNi845x(ni845x,CS_B,'0011'));
        aligned_values(12,1) = convertCharsToStrings(readNi845x(ni845x,CS_B,'0012'));
        aligned_values(13,1) = convertCharsToStrings(dec2hex(csa_zero));
        aligned_values(14,1) = convertCharsToStrings(dec2hex(csb_zero));
        break;
    else
        values_found = 0;
    end
    csa_zero = 0;
    csb_zero = 0;
    if channel_start < 4
        csa_zero = good_values(2,n,channel_start)*2^((good_values(3,n,channel_start)-1)*4);
        cs_data = csa_zero;
        cs = CS_A;
        mux_addr = 15 + channel_start;
    else
        csb_zero = good_values(2,n,channel_start)*2^((good_values(3,n,channel_start)-1)*4);
        cs_data = csb_zero;
        cs = CS_B;
        mux_addr = 12 + channel_start;
    end
    channel_index(channel_start) = n;
    data = dec2hex(cs_data,4);
    writeNi845x(ni845x, cs, '0000', data);
    mux_addr = dec2hex(mux_addr, 4);
    data = dec2hex(good_values(4,n,channel_start),4);
    writeNi845x(ni845x, cs, mux_addr, data);
    if adc.num == 1
        adc_addr = dec2hex(channel_start-1, 4);
    else
        adc_addr = dec2hex(channel_start+7, 4);
    end
    data = dec2hex(good_values(1,n,channel_start),4);
    writeNi845x(ni845x, CS.RFIC, adc_addr, data);
    for i = 1:5
        if next_start
            next_start = false;
            break;
        end
        channel_current = mod(channel_start + i, 6);
        if channel_current == 0
            channel_current = 6;
        end
        status = ['Adjusting for channel ', num2str(channel_current)];
        disp(status)
        if channel_current < 4
            cs = CS_A;
            mux_addr = 15 + channel_current;
        else
            cs = CS_B;
            mux_addr = 12 + channel_current;
        end
        mux_addr = dec2hex(mux_addr,4);
        for j = 1:channel_length(channel_current)
            if j == channel_length(channel_current)
                status = ['No matches found for channel ', num2str(channel_current), '!'];
                disp(status);
                next_start = true;
                break;
            end
            if channel_current < 4
                cs_data = csa_zero + good_values(2,j,channel_current)*2^((good_values(3,j,channel_current)-1)*4);
            else
                cs_data = csb_zero + good_values(2,j,channel_current)*2^((good_values(3,j,channel_current)-1)*4);
            end
            if checkValue(cs_data)
                data = dec2hex(cs_data, 4);
                writeNi845x(ni845x, cs, '0000', data);
                data = dec2hex(good_values(4,j,channel_current),4);
                writeNi845x(ni845x, cs, mux_addr, data);
                if adc.num == 1
                    adc_addr = dec2hex(channel_current-1, 4);
                else
                    adc_addr = dec2hex(channel_current+7, 4);
                end
                data = dec2hex(good_values(1,j,channel_current),4);
                writeNi845x(ni845x, CS.RFIC, adc_addr, data);
                channel_vecs = getChannels(LA, true);
                channel_index(channel_current) = j;
                first_four_start = firstFour(channel_vecs(:,:,channel_start),adc.cycle);
                first_four_current = firstFour(channel_vecs(:,:,channel_current),adc.cycle);
                distance = abs(first_four_start - first_four_current);
                status = ['Distance is ', num2str(distance)];
                disp(status);
                if distance < 3
                    values_found = values_found + 1;
                    if cs == CS_A
                        csa_zero = cs_data;
                    else
                        csb_zero = cs_data;
                    end
                    break;
                end
            end
        end
    end
end
[CH_A, CH_B] = update(LA, true);
[adc_odds, adc_evens, unassigned] = identify(CH_A.str, CH_B.str, adc.sample_ratio);

if ~isempty(unassigned)
    disp(unassigned);
    error('Shit Unassigned?!');
end
first_12_top = first12(CH_A.vec, adc.cycle);
first_12_bot = first12(CH_B.vec, adc.cycle);

status = 'Alignment sucessful';
disp(status);