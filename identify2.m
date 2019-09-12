function success = identify2(CH0A_str, CH0B_str, sample_ratio)

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
success = true;
for i=1:12
    for n=1:length(CH0A_str)-(max_string_length-1)
        if strcmp(CH0A_str(i,n:n+length(three_ones)-1),three_ones) && (strcmp(CH0A_str(i,n:n+length(alternating)-1),alternating) ||...
                strcmp(CH0A_str(i,n:n+length(alternating2)-1),alternating2))
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif strcmp(CH0A_str(i,n:n+length(two_ones_two_zeros)-1),two_ones_two_zeros) && strcmp(CH0A_str(i,n:n+length(three_ones)-1),three_ones)
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif strcmp(CH0A_str(i,n:n+length(three_zeros)-1),three_zeros) && (strcmp(CH0A_str(i,n:n+length(alternating)-1),alternating) ||...
                strcmp(CH0A_str(i,n:n+length(alternating2)-1),alternating2))
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif (strcmp(CH0A_str(i,n:n+length(alternating)-1),alternating) ||...
                strcmp(CH0A_str(i,n:n+length(alternating2)-1),alternating2)) && strcmp(CH0A_str(i,n:n+length(two_ones_two_zeros)-1),two_ones_two_zeros)
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif strcmp(CH0A_str(i,n:n+length(three_zeros)-1),three_zeros) && strcmp(CH0A_str(i,n:n+length(three_ones)-1),three_ones)
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif strcmp(CH0A_str(i,n:n+length(three_zeros)-1),three_zeros) && strcmp(CH0A_str(i,n:n+length(two_ones_two_zeros)-1),two_ones_two_zeros)
            warning('This waveform is incorrect');
            success = false;
            break;
        end
    end
end

for i=13:24
    for n=1:length(CH0B_str)-(max_string_length-1)
        if strcmp(CH0B_str(i-12,n:n+length(three_ones)-1),three_ones) && (strcmp(CH0B_str(i-12,n:n+length(alternating)-1),alternating) ||...
                strcmp(CH0B_str(i-12,n:n+length(alternating2)-1),alternating2))
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif strcmp(CH0B_str(i-12,n:n+length(two_ones_two_zeros)-1),two_ones_two_zeros) && strcmp(CH0B_str(i-12,n:n+length(three_ones)-1),three_ones)
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif strcmp(CH0B_str(i-12,n:n+length(three_zeros)-1),three_zeros) && (strcmp(CH0B_str(i-12,n:n+length(alternating)-1),alternating) ||...
                strcmp(CH0B_str(i-12,n:n+length(alternating2)-1),alternating2))
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif (strcmp(CH0B_str(i-12,n:n+length(alternating)-1),alternating) ||...
                strcmp(CH0B_str(i-12,n:n+length(alternating2)-1),alternating2)) && strcmp(CH0B_str(i-12,n:n+length(two_ones_two_zeros)-1),two_ones_two_zeros)
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif strcmp(CH0B_str(i-12,n:n+length(three_zeros)-1),three_zeros) && strcmp(CH0B_str(i-12,n:n+length(three_ones)-1),three_ones)
            warning('This waveform is incorrect');
            success = false;
            break;
        elseif strcmp(CH0B_str(i-12,n:n+length(three_zeros)-1),three_zeros) && strcmp(CH0B_str(i-12,n:n+length(two_ones_two_zeros)-1),two_ones_two_zeros)
            warning('This waveform is incorrect');
            success = false;
            break;
        end
    end
end
