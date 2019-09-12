LA_config = 'config1.ala';
LA = openLA(LA_config);

samples = 50;
size = samples + 2;
vec_sum = zeros(24,size);
for i = 1:samples
    [CH0A, CH0B] = update(LA, true);
    CH0A0B = [CH0A.str; CH0B.str];
    CH0A0B_vec = [CH0A.vec;CH0B.vec];
    vec_sum(:,i) = sum(CH0A0B_vec, 2);
end
vec_sum(:,samples +1) = mean(vec_sum,2);
vec_sum(:,samples +2) = std(vec_sum,[],2);