function success = identifyFives(vec_sum, vec_length, start)

count = zeros(1,2);
for i= start:start+3
    if vec_sum(i) >= vec_length - 5
        count(1) = count(1) + 1;
    elseif vec_sum(i) <= 5
        count(2) = count(2) + 1;
    end
end

total = sum(count);
if total == 4
    success = true;
else
    success = false;
end