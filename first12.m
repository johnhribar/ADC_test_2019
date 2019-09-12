function first_12 = first12(vec_ch, cycle)
% Add up all the columns in each of the output vectors
vec_sum = sum(vec_ch);

% Find the first time outside the first clock cycle that there are all ones
% in a column for each of the output vectors
first_12 = 0;

for i = cycle:length(vec_sum)
    if vec_sum(i)==12 && vec_sum(i-1)~=12
        first_12 = i;
        break
    end
end

if first_12 == 0
    error('Could not find a position where all data aligns. Please try again')
end