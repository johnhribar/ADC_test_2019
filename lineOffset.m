function line_offset = lineOffset(CH0A_vec,CH0B_vec,...
    adc_odds, adc_evens, first_12_top, first_12_bot, cycle)

line_offset.odd = zeros(1,12);
line_offset.even = zeros(1,12);
% For each of the channels calculate how many samples there are 
% before the first time a one appears on every line
for n = 1:12
    if n < 7
        for i = first_12_top-1:-1:first_12_top-cycle
            if CH0A_vec(adc_odds(1,n),i) == 0
                break
            else
                line_offset.odd(n) = line_offset.odd(n) + 1;
%                 if line_offset.odd(n) > line_offset.max
%                     line_offset.max = line_offset.odd(n);
%                 end
            end
        end
        for i = first_12_bot-1:-1:first_12_bot-cycle
            if CH0B_vec(adc_odds(1,n+6)-12,i) == 0
                break
            else
                line_offset.odd(n+6) = line_offset.odd(n+6) + 1;
            end
        end
    else
        for i = first_12_top-1:-1:first_12_top-cycle
            if CH0A_vec(adc_evens(1,n-6),i) == 0
                break
            else
                line_offset.even(n-6) = line_offset.even(n-6) + 1;
            end
        end
        for i = first_12_bot-1:-1:first_12_bot-cycle
            if CH0B_vec(adc_evens(1,n)-12,i) == 0
                break
            else
                line_offset.even(n) = line_offset.even(n) + 1;
            end
        end
    end
end

% Find out if the first channel has all ones first or the second channel
% and offset the other channel accordingly
if first_12_top > first_12_bot
    diff = first_12_top - first_12_bot;
    for n = 1:12
        if n < 7
            line_offset.odd(n) = line_offset.odd(n) - diff;
        else
            line_offset.even(n-6) = line_offset.even(n-6) - diff;
        end
    end
elseif first_12_top < first_12_bot
    diff = first_12_bot - first_12_top;
    for n = 1:12
        if n < 7
            line_offset.odd(n+6) = line_offset.odd(n+6) - diff;
        else
            line_offset.even(n) = line_offset.even(n) - diff;
        end
    end
end

for i = 1:length(line_offset.odd)
    if abs(line_offset.odd(i)) > (cycle / 2)
        line_offset.odd = mod(line_offset.odd, cycle);
    end
    if abs(line_offset.even(i)) > (cycle / 2)
        line_offset.even = mod(line_offset.even, cycle);
    end
end

line_offset.ordered = zeros(2,12);
for i = 1:12
    row_odd = ceil(adc_odds(1,i)/12);
    col_odd = mod(adc_odds(1,i),12);
    if col_odd == 0
        col_odd = 12;
    end
    row_even = ceil(adc_evens(1,i)/12);
    col_even = mod(adc_evens(1,i),12);
    if col_even == 0
        col_even = 12;
    end
    line_offset.ordered(row_odd, col_odd) = line_offset.odd(i);
    line_offset.ordered(row_even, col_even) = line_offset.even(i);
end

min_offset = min(line_offset.ordered, [], 'all');
line_offset.plus_minus = line_offset.ordered;
line_offset.ordered = line_offset.ordered - min_offset;
line_offset.max = max(line_offset.ordered, [], 'all');
    