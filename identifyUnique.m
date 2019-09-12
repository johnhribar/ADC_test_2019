function success = identifyUnique(CH_str, sample_ratio, start, cycle, vec_sum)

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
str_length = length(CH_str);
dev = 25;
% disp(three_ones)
% disp(two_ones_two_zeros)
% disp(three_zeros)
% disp(alternating)
count = zeros(1,4);
begin = zeros(1,4);
for i= start:start+3
    for n = 2*cycle:length(CH_str)-(max_string_length-1)
        if strcmp(CH_str(i,n:n+length(three_ones)-1),three_ones)
            if vec_sum(i) >= (str_length * .75 + dev) || vec_sum(i) <= (str_length * .75 - dev)
                break;
            else
            count(1) = 1;
            begin(1) = n;
            break;
            end
        elseif strcmp(CH_str(i,n:n+length(two_ones_two_zeros)-1),two_ones_two_zeros)
            if vec_sum(i) >= (str_length * .5 + dev) || vec_sum(i) <= (str_length * .5 - dev)
                break;
            else
            count(2) = 1;
            begin(2) = n;
            break;
            end
        elseif strcmp(CH_str(i,n:n+length(three_zeros)-1),three_zeros)
           if vec_sum(i) >= (str_length * .25 + dev) || vec_sum(i) <= (str_length * .25 - dev)
                break;
            else
            count(3) = 1;
            begin(3) = n;
            break;
            end
        elseif strcmp(CH_str(i,n:n+length(alternating)-1),alternating) ||...
                strcmp(CH_str(i,n:n+length(alternating2)-1),alternating2)
           if vec_sum(i) >= (str_length * .5 + dev) || vec_sum(i) <= (str_length * .5 - dev)
                break;
            else
            count(4) = 1;
            begin(4) = n;
            break;
            end
        end
    end
end

total = sum(count);
begin = mod(begin, cycle);
if abs(begin(3) - begin(4)) > abs(begin(3) - begin(4) - cycle/2)
    begin(4) = mod(begin(4) - cycle/2,20);
end
S = std(begin);
if total == 4 && S < 1
    success = true;
% elseif total > 2
%     prompt = 'Type 1 if waveform is correct: ';
%     test = input(prompt);
%     if test == 1
%         success = true;
%     else
%         success = false;
%     end
else
    success = false;
end