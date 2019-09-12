function channels = testValuesUnique(ni845x, LA, CS, adc)

% Places ADC in static value mode and sets up RCASICs
adc_str = ['ADC', num2str(adc.num), '_CONFIG_UNIQUE_ALT.txt'];
registerWrite(ni845x, adc_str, 'ADC')
registerWrite(ni845x, 'RCASIC_CONF', 'RCASIC')

if adc.num == 1
    CS_A = CS.RC0A;
    CS_B = CS.RC0B;
else
    CS_A = CS.RC1A;
    CS_B = CS.RC1B;
end

ok_values = [0 1 2 3 4 6 7 8 9 12 14 15];
channels = zeros(4,75,6);

for i = 0:2
    index = 1;
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
    for mux = 0:3
        address = 16 + i;
        address = dec2hex(address,4);
        data = dec2hex(mux,4);
        writeNi845x(ni845x, CS_A, address, data);
        status = ['Tests for multiplexer setting ', num2str(mux),'...'];
        disp(status)
        for j = 1:12
            data = ok_values(j) * 2^(i*4);
            data = dec2hex(data, 4);
            writeNi845x(ni845x, CS_A, '0000', data);
            for k = 0:7
                data = dec2hex(k,4);
                address = dec2hex(i,4);
                writeNi845x(ni845x, CS.RFIC, address, data);
                [CH0A, ~] = update(LA, true);
                success = identifyUnique(CH0A.str, adc.sample_ratio, start, adc.cycle);
                if success
                    channels(1, index, i+1) = k;
                    channels(2, index, i+1) = ok_values(j);
                    channels(3, index, i+1) = i+1;
                    channels(4, index, i+1) = mux;
                    index = index + 1;
                    if index > 75
                        index = 75;
                        warning('More values than we gave room for!')
                    end
                end
            end
        end
    end
end

for i = 0:2
    index = 1;
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
    for mux = 0:3
        address = 16 + i;
        address = dec2hex(address,4);
        data = dec2hex(mux,4);
        writeNi845x(ni845x, CS_B, address, data);
        status = ['Tests for multiplexer setting ', num2str(mux),'...'];
        disp(status)
        for j = 1:12
            data = ok_values(j) * 2^(i*4);
            data = dec2hex(data, 4);
            writeNi845x(ni845x, CS_B, '0000', data);
            for k = 0:7
                data = dec2hex(k,4);
                address = dec2hex((i+3),4);
                writeNi845x(ni845x, CS.RFIC, address, data);
                [~, CH0B] = update(LA, true);
                success = identifyUnique(CH0B.str, adc.sample_ratio, start, adc.cycle);
                if success
                    channels(1, index, i+4) = k;
                    channels(2, index, i+4) = ok_values(j);
                    channels(3, index, i+4) = i+1;
                    channels(4, index, i+4) = mux;
                    index = index + 1;
                    if index > 75
                        index = 75;
                        warning('More values than we gave room for!')
                    end
                end
            end
        end
    end
end

% totals = transpose(squeeze(sum(channels)));
% [getzeros(:,1), getzeros(:,2)] = find(~totals);
% if getzeros(1,2) == 1
%     status = ['Unable to find a correct value for channel ', num2str(getzeros(1,1))];
%     error(status);
% else
%     short_channel.num = getzeros(1,1);
%     short_channel.length = getzeros(2,1) - 1;
% end