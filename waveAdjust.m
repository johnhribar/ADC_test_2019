function [CH0A, CH0B] = waveAdjust(ni845x, LA, adc, adc_odds, adc_evens)
CS = 4;
address_prev = '8888';

if adc == 1
    offset = 0;
else
    offset = 8;
end

status = 'Adjusting waveform...';
disp(status)
for i = 1:length(adc_odds)
    if adc_odds(i) == 0 || adc_evens(i) == 0
        address = ceil(i/2) - 1 + offset;
        address = dec2hex(address, 4);
        data = hex2dec(readNi845x(ni845x, CS, address)) + 1;
        data = dec2hex(mod(data, 8),4);
        if address ~= address_prev
            writeNi845x(ni845x, CS, address, data);
            address_prev = address;
        end
    end
end

[CH0A, CH0B] = update(LA, true);

