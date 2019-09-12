function signal = getSignal(LA, adc_evens, adc_odds, clk_str, clock)

%% Channel Stuff
% Runs the logic analyzer and updates CH0A and CH0B
[CH0A, CH0B] = update(LA, true);

%% Clock Stuff
[CLK0A, CLK0B] = getClock(LA, false);

if strcmp(clock, 'A')
    clk = CLK0A.vec;
else
    clk = CLK0B.vec;
end
clock_edges = clockEdge(clk, clk_str);

%% Reconstruction Stuff
CH0A0B = [CH0A.vec;CH0B.vec];

% Reconstruct vectors, sorting by odds and evens and appropriately offset

clocked_odd = zeros(12, length(clock_edges));
clocked_even = zeros(12, length(clock_edges));
for i = 1:length(clock_edges)
    for j = 1:12
        clocked_odd(j,i) = CH0A0B(adc_odds(j), clock_edges(i));
        clocked_even(j,i) = CH0A0B(adc_evens(j), clock_edges(i));
    end
end

signal.clocked_signal = zeros(12, length(clocked_odd)*2);
for k = 1:12
    j = 1;
    for i = 1:length(clocked_odd)
        signal.clocked_signal(k,j) = clocked_odd(k,i);
        signal.clocked_signal(k,j+1) = clocked_even(k,i);
        j = j+2;
    end
end

signal2s = zeros(12, length(signal.clocked_signal));
for n = 1:12
    signal2s(n,:) = 2^(n-1).*signal.clocked_signal(n,:);
end
signal.constructed = sum(signal2s);

