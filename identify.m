function [adc_odds, adc_evens, unassigned] = identify(CH0A_str, CH0B_str, sample_ratio)

adc_odds = zeros(1,12);
adc_evens = zeros(1,12);

ones_str_short = repmat('1',1,floor(sample_ratio));
ones_str_long = repmat('1',1,ceil(sample_ratio));
zero_str_short = repmat('0',1,floor(sample_ratio));
zero_str_long = repmat('0',1,ceil(sample_ratio));

three_ones = strcat(ones_str_short, ones_str_long, ones_str_short);
two_ones_two_zeros = strcat(zero_str_short, zero_str_short, ones_str_short, ones_str_short);
three_zeros = strcat(zero_str_short, zero_str_long, zero_str_short);
alternating = strcat('0',ones_str_short, zero_str_long, '1');
alternating2 = strcat('1',zero_str_short, ones_str_long, '0');

max_string_length = length(two_ones_two_zeros);
% disp(three_ones)
% disp(two_ones_two_zeros)
% disp(three_zeros)
% disp(alternating)
for i=1:12
    channel = ceil(i/4);
    for n=1:length(CH0A_str)-(max_string_length-1)
        if strcmp(CH0A_str(i,n:n+length(three_ones)-1),three_ones)
            switch channel
                case 1
                    adc_odds(1) = i;
                case 2
                    adc_odds(3) = i;
                case 3
                    adc_odds(5) = i;
            end
            break;
        elseif strcmp(CH0A_str(i,n:n+length(two_ones_two_zeros)-1),two_ones_two_zeros)
            switch channel
                case 1
                    adc_odds(2) = i;
                case 2
                    adc_odds(4) = i;
                case 3
                    adc_odds(6) = i;
            end
            break;
        elseif strcmp(CH0A_str(i,n:n+length(three_zeros)-1),three_zeros)
            switch channel
                case 1
                    adc_evens(2) = i;
                case 2
                    adc_evens(4) = i;
                case 3
                    adc_evens(6) = i;
            end
            break;
        elseif strcmp(CH0A_str(i,n:n+length(alternating)-1),alternating) ||...
                strcmp(CH0A_str(i,n:n+length(alternating2)-1),alternating2)
            switch channel
                case 1
                    adc_evens(1) = i;
                case 2
                    adc_evens(3) = i;
                case 3
                    adc_evens(5) = i;
            end
            break;
        end
    end
end

for i=13:24
    channel = ceil(i/4);
    for n=1:length(CH0B_str)-(max_string_length-1)
        if strcmp(CH0B_str(i-12,n:n+length(three_ones)-1),three_ones)
            switch channel
                case 4
                    adc_odds(7) = i;
                case 5
                    adc_odds(9) = i;
                case 6
                    adc_odds(11) = i;
            end
            break;
        elseif strcmp(CH0B_str(i-12,n:n+length(two_ones_two_zeros)-1),two_ones_two_zeros)
            switch channel
                case 4
                    adc_odds(8) = i;
                case 5
                    adc_odds(10) = i;
                case 6
                    adc_odds(12) = i;
            end
            break;
        elseif strcmp(CH0B_str(i-12,n:n+length(three_zeros)-1),three_zeros)
            switch channel
                case 4
                    adc_evens(8) = i;
                case 5
                    adc_evens(10) = i;
                case 6
                    adc_evens(12) = i;
            end
            break;
        elseif strcmp(CH0B_str(i-12,n:n+length(alternating)-1),alternating) ||...
                strcmp(CH0B_str(i-12,n:n+length(alternating2)-1),alternating2)
            switch channel
                case 4
                    adc_evens(7) = i;
                case 5
                    adc_evens(9) = i;
                case 6
                    adc_evens(11) = i;
            end
            break;
        end
    end
end
adc_all = [adc_odds, adc_evens];
unassigned = find(~adc_all);

if length(unassigned) < 3
    disp(adc_all(1:12));
    disp(adc_all(13:24));
    disp(unassigned);
    for i = 1:length(unassigned)
        prompt = ['Enter value for missing channel ', num2str(unassigned(i)), ': '];
        value = input(prompt);
        if unassigned(i) > 12
            adc_evens(unassigned(i)-12) = value;  
        else
            adc_odds(unassigned(i)) = value;
        end
    end
end

adc_all = [adc_odds, adc_evens];
unassigned = find(~adc_all);