function channel_match = testValuesAlt(ni845x, LA, CS, adc, good_values, waveform)

% Places ADC in static value mode and sets up RCASICs
adc_str = ['ADC', num2str(adc.num), '_CONFIG_',waveform,'.txt'];
registerWrite(ni845x, adc_str, 'ADC')

totals = transpose(squeeze(sum(good_values)));
[channel_number, position] = find(~totals);
channel_length = zeros(1,6);
channel_length_max = 0;
if position(1) == 1
    status = ['Unable to find a good value for channel ', num2str(getzeros(1,1))];
    error(status);
else
    for i = 1:6
        occurances = find(channel_number==i);
        if isempty(occurances)
            channel_length(i) = length(good_values);
            channel_length_max = channel_length(i);
        else
            channel_length(i) = position(occurances(1)) - 1;
            if channel_length(i) > channel_length_max
                channel_length_max = channel_length(i);
            end
        end
    end 
end

if adc.num == 1
    CS_A = CS.RC0A;
    CS_B = CS.RC0B;
else
    CS_A = CS.RC1A;
    CS_B = CS.RC1B;
end
channel_match = zeros(4,channel_length_max,6);
for channel_count = 1:3
    index = 1;
    for n = 1:channel_length(channel_count)
        i = good_values(3,n,channel_count) - 1;
        j = good_values(2,n,channel_count);
        k = good_values(1,n,channel_count);
        mux = good_values(4,n,channel_count);
        switch i
            case 0
                channel = 'CH0A, low';
            case 1
                channel = 'CH0A, mid';
            case 2
                channel = 'CH0A, high';
        end
        status = ['Trying options for ', channel, '...'];
        disp(status);
        start = 4*i + 1;
        data = j * 2^(i*4);
        data = dec2hex(data, 4);
        writeNi845x(ni845x, CS_A, '0000', data);
        data = dec2hex(mux,4);
        writeNi845x(ni845x, CS_A, '0010', data);
        writeNi845x(ni845x, CS_A, '0011', data);
        writeNi845x(ni845x, CS_A, '0012', data);
        data = dec2hex(k,4);
        if adc.num == 1
            address = i;
        else
            address = i + 8;
        end
        address = dec2hex(address,4);
        writeNi845x(ni845x, CS.RFIC, address, data);
        [CH0A, ~] = update(LA, true);
        vec_sum = sum(CH0A.vec, 2);
        switch waveform
            case 'BR1'
                success = identifyBR1(CH0A.str, adc.sample_ratio, start, adc.cycle, 1);
            case 'BR5'
                success = identifyBR5(CH0A.str, adc.sample_ratio, start, adc.cycle, 1);
            case 'tog'
                success = identifyTog(CH0A.str, adc.sample_ratio, start, adc.cycle);
            case 'FIRST'
                success = identifyUnique(CH0A.str, adc.sample_ratio, start, adc.cycle, vec_sum);
                if ~success
                    disp('Some value has shifted')
                end
        end
        if success
            channel_match(1, index, channel_count) = k;
            channel_match(2, index, channel_count) = j;
            channel_match(3, index, channel_count) = i + 1;
            channel_match(4, index, channel_count) = mux;
            index = index + 1;
        end
    end
end
for channel_count = 4:6
    index = 1;
    for n = 1:channel_length(channel_count)
        i = good_values(3,n,channel_count) - 1;
        j = good_values(2,n,channel_count);
        k = good_values(1,n,channel_count);
        mux = good_values(4,n,channel_count);
        switch i
            case 0
                channel = 'CH0B, low';
            case 1
                channel = 'CH0B, mid';
            case 2
                channel = 'CH0B, high';
        end
        status = ['Trying options for ', channel, '...'];
        disp(status);
        start = 4*i + 1;
        data = j * 2^(i*4);
        data = dec2hex(data, 4);
        writeNi845x(ni845x, CS_B, '0000', data);
        data = dec2hex(mux, 4);
        writeNi845x(ni845x, CS_B, '0010', data)
        writeNi845x(ni845x, CS_B, '0011', data)
        writeNi845x(ni845x, CS_B, '0012', data)
        data = dec2hex(k,4);
        if adc.num == 1
            address = i;
        else
            address = i + 8;
        end
        address = dec2hex(address,4);
        writeNi845x(ni845x, CS.RFIC, address, data);
        [~, CH0B] = update(LA, true);
        switch waveform
            case 'BR1'
                success = identifyBR1(CH0B.str, adc.sample_ratio, start, adc.cycle, 2);
            case 'BR5'
                success = identifyBR5(CH0B.str, adc.sample_ratio, start, adc.cycle, 2);
            case 'tog'
                success = identifyTog(CH0B.str, adc.sample_ratio, start, adc.cycle);
            case 'FIRST'
                success = identifyUnique(CH0B.str, adc.sample_ratio, start, adc.cycle, vec_sum);
                if ~success
                    disp('Some value has shifted')
                end
        end
        if success
            channel_match(1, index, channel_count) = k;
            channel_match(2, index, channel_count) = j;
            channel_match(3, index, channel_count) = i + 1;
            channel_match(4, index, channel_count) = mux;
            index = index + 1;
        end
    end
end


