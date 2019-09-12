function channels = testValuesUniqueAlt(ni845x, LA, CS, adc)

% Places ADC in static value mode and sets up RCASICs
adc_str = ['ADC', num2str(adc.num), '_CONFIG_UNIQUE.txt'];
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
dumb_spi_workaround = [0,2,3,5];
dumb_spi_workaround_2 = [1,4];

writeNi845x(ni845x, CS_A, '0000', '0000');
writeNi845x(ni845x, CS_B, '0000', '0000');
index = ones(1,4);
for mux = 0:3
    data = dec2hex(mux,4);
    writeNi845x(ni845x, CS_A, '0010', data);
    writeNi845x(ni845x, CS_A, '0012', data);
    writeNi845x(ni845x, CS_B, '0010', data);
    writeNi845x(ni845x, CS_B, '0012', data);
    status = ['Tests for multiplexer setting ', num2str(mux),'...'];
    disp(status)
    for j = 1:12
        data = ok_values(j) + ok_values(j)*256;
        data = dec2hex(data, 4);
        writeNi845x(ni845x, CS_A, '0000', data);
        writeNi845x(ni845x, CS_B, '0000', data);
        for k = 0:7
            data = dec2hex(k,4);
            writeNi845x(ni845x, CS.RFIC, adc.delay1, data);
            writeNi845x(ni845x, CS.RFIC, adc.delay3, data);
            writeNi845x(ni845x, CS.RFIC, adc.delay4, data);
            writeNi845x(ni845x, CS.RFIC, adc.delay6, data);
            [CH0A, CH0B] = update(LA, true);
            CH0A0B = [CH0A.str; CH0B.str];
            CH0A0B_vec = [CH0A.vec;CH0B.vec];
            vec_sum = sum(CH0A0B_vec, 2);
            for i = 1:4
                start = 4*dumb_spi_workaround(i) + 1;
                success = identifyUnique(CH0A0B, adc.sample_ratio, start, adc.cycle, vec_sum); % passed vec_sum
                if success
                    channels(1, index(i), dumb_spi_workaround(i)+1) = k;
                    channels(2, index(i), dumb_spi_workaround(i)+1) = ok_values(j);
                    channels(3, index(i), dumb_spi_workaround(i)+1) = mod(dumb_spi_workaround(i),3)+1;
                    channels(4, index(i), dumb_spi_workaround(i)+1) = mux;
                    index(i) = index(i) + 1;
                    if index(i) > 75
                        index(i) = 75;
                        warning('More values than we gave room for!')
                    end
                end
            end
        end
    end
end

writeNi845x(ni845x, CS_A, '0000', '0000');
writeNi845x(ni845x, CS_B, '0000', '0000');
index2 = ones(1,2);
for mux = 0:3
    data = dec2hex(mux,4);
    writeNi845x(ni845x, CS_A, '0011', data);
    writeNi845x(ni845x, CS_B, '0011', data);
    status = ['Tests for multiplexer setting ', num2str(mux),'...'];
    disp(status)
    for j = 1:12
        data = ok_values(j)*16;
        data = dec2hex(data, 4);
        writeNi845x(ni845x, CS_A, '0000', data);
        writeNi845x(ni845x, CS_B, '0000', data);
        for k = 0:7
            data = dec2hex(k,4);
            writeNi845x(ni845x, CS.RFIC, adc.delay2, data);
            writeNi845x(ni845x, CS.RFIC, adc.delay5, data);
            [CH0A, CH0B] = update(LA, true);
            CH0A0B = [CH0A.str; CH0B.str];
            CH0A0B_vec = [CH0A.vec;CH0B.vec];
            vec_sum = sum(CH0A0B_vec, 2);
            for i = 1:2
                start = 4*dumb_spi_workaround_2(i) + 1;
                success = identifyUnique(CH0A0B, adc.sample_ratio, start, adc.cycle, vec_sum);
                if success
                    channels(1, index2(i), dumb_spi_workaround_2(i)+1) = k;
                    channels(2, index2(i), dumb_spi_workaround_2(i)+1) = ok_values(j);
                    channels(3, index2(i), dumb_spi_workaround_2(i)+1) = mod(dumb_spi_workaround_2(i),3)+1;
                    channels(4, index2(i), dumb_spi_workaround_2(i)+1) = mux;
                    index2(i) = index2(i) + 1;
                    if index2(i) > 75
                        index2(i) = 75;
                        warning('More values than we gave room for!')
                    end
                end
            end
        end
    end
end