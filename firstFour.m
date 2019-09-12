function first_4 = firstFour(vec_ch, cycle)
% Add up all the columns in each of the output vectors
vec_sum = sum(vec_ch);

% Find the first time outside the first clock cycle that there are all ones
% in a column for each of the output vectors
first_4 = 0;

for i = cycle:length(vec_sum)
    if vec_sum(i)==4 && vec_sum(i-1) ~= 4
        disp(i)
        first_4 = mod(i,cycle);
        break
    end
end