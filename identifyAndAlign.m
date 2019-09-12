function [adc_odds, adc_evens, first_12_top, first_12_bot,...
    CH0A, CH0B] = identifyAndAlign(ni845x, LA, CH0A, CH0B, CS, adc, cycle, sample_ratio)

if adc == 1
    CSA = CS.RC0A;
    CSB = CS.RC0B;
else
    CSA = CS.RC1A;
    CSB = CS.RC1B;
end

is_aligned = false;
is_identified = false;
trigger_once = true;
while ~is_identified || ~is_aligned
    
    if ~is_identified
        %Identifies which channel is which signal
        status = 'Attempting to identify channels...';
        disp(status)
        [adc_odds, adc_evens, unassigned] = identify(CH0A.str, CH0B.str, sample_ratio);
        disp('Unassigned: ');
        disp(unassigned);
        if ~isempty(unassigned)
            [CH0A, CH0B] = waveAdjust(ni845x, LA, adc, adc_odds, adc_evens);
            is_identified = false;
            is_aligned = false;
        else
            is_identified = true;
            status = 'Identification Successful.';
            disp(status);
        end
    end
    
    if ~is_aligned && is_identified
        status = 'Attempting to align channels...';
        disp(status)
        is_aligned = true;
        first_12_top = first12(CH0A.vec, cycle);
        first_12_bot = first12(CH0B.vec, cycle);
        
        if first_12_top == 0
            [CH0A, CH0B, first_12_top, first_12_bot,...
                is_aligned, is_identified] = first12Adjust(ni845x, LA, CSA, cycle);
        end
        if first_12_bot == 0
            [CH0A, CH0B, first_12_top, first_12_bot,...
                is_aligned, is_identified] = first12Adjust(ni845x, LA, CSB, cycle);
        end
    end
    
    if trigger_once && is_identified && is_aligned
        status = 'Dumping Register Writes...';
        disp(status)
        adc_str = ['ADC', num2str(adc), '_delays.txt'];
        registerWrite(ni845x, adc_str, 'ADC')
        [CH0A, CH0B] = update(LA, true);
        is_aligned = false;
        is_identified = false;
        trigger_once = false;
    end

end
status = 'Alignment sucessful';
disp(status);