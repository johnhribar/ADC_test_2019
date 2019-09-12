function success = identifyBR1(CH_str, sample_ratio, start, cycle, rcasic)

ones_str_short = repmat('1',1,floor(sample_ratio));
ones_str_long = repmat('1',1,ceil(sample_ratio));
zero_str_short = repmat('0',1,floor(sample_ratio));
zero_str_long = repmat('0',1,ceil(sample_ratio));

three_ones = strcat(ones_str_short, ones_str_long, ones_str_short);
two_ones_two_zeros = strcat(ones_str_short, ones_str_short, zero_str_short, zero_str_short);
three_zeros = strcat(ones_str_short, zero_str_short, zero_str_long, zero_str_short);
alternating = strcat(ones_str_short, zero_str_long, ones_str_short, '0');
alternating2 = strcat(ones_str_short,zero_str_short, ones_str_long, '0');

max_string_length = length(three_zeros);
% disp(three_ones)
% disp(two_ones_two_zeros)
% disp(three_zeros)
% disp(alternating)
count = zeros(1,4);
if rcasic == 2 && start == 5
    for i= start:start+3
        for n = cycle:length(CH_str)-(max_string_length-1)
            if strcmp(CH_str(i,n:n+length(three_ones)-1),three_ones)
                count(1) = count(1) + 1;
                break;
            end
        end
    end
else
    for i= start:start+3
        for n = cycle:length(CH_str)-(max_string_length-1)
            if strcmp(CH_str(i,n:n+length(three_zeros)-1),three_zeros)
                count(1) = count(1) + 1;
                break;
            end
        end
    end
end

total = sum(count);
if total == 4
    success = true;
else
    success = false;
end