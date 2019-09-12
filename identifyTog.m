function success = identifyTog(CH_str, sample_ratio, start, cycle)

ones_str_short = repmat('1',1,floor(sample_ratio));
ones_str_long = repmat('1',1,ceil(sample_ratio));
zero_str_short = repmat('0',1,floor(sample_ratio));
zero_str_long = repmat('0',1,ceil(sample_ratio));

three_ones = strcat(ones_str_short, ones_str_long, ones_str_short);
three_zeros = strcat(ones_str_short, zero_str_short, zero_str_long, zero_str_short);

max_string_length = length(three_zeros);

count = zeros(1,2);
for i= start:start+3
    for n = 2*cycle:length(CH_str)-(max_string_length-1)
        if strcmp(CH_str(i,n:n+length(three_ones)-1),three_ones)
            count(1) = count(1) + 1;
            break;
        elseif strcmp(CH_str(i,n:n+length(three_zeros)-1),three_zeros)
            count(2) = count(2) + 1;
            break;
        end
    end
end

total = sum(count);
if total == 4
    success = true;
else
    success = false;
end