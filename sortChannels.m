function [correct, short_channel] = sortChannels(CH_A, CH_B)
CH_A(3,:) = CH_A(3,:) + 1;
CH_B(3,:) = CH_B(3,:) + 4;
channel_index = ones(6,1);

for i = 1:length(CH_A)
    channel = CH_A(3,i);
    switch channel
        case 1
            correct(:, channel_index(1,1),channel) = CH_A(:,i);
            channel_index(1,1) = channel_index(1,1) + 1;
        case 2
            correct(:, channel_index(2,1), channel) = CH_A(:,i);
            channel_index(2,1) = channel_index(2,1) + 1;
        case 3
            correct(:, channel_index(3,1), channel) = CH_A(:,i);
            channel_index(3,1) = channel_index(3,1) + 1;
    end
end

for i = 1:length(CH_B)
    channel = CH_B(3,i);
    switch channel
        case 4
            correct(:, channel_index(4,1), channel) = CH_B(:,i);
            channel_index(4,1) = channel_index(4,1) + 1;
        case 5
            correct(:, channel_index(5,1), channel) = CH_B(:,i);
            channel_index(5,1) = channel_index(5,1) + 1;
        case 6
            correct(:, channel_index(6,1), channel) = CH_B(:,i);
            channel_index(6,1) = channel_index(6,1) + 1;
    end
end
shortest_channel = 1000;
for i = 1:length(channel_index)
    if channel_index(i,1) < shortest_channel
        shortest_channel = i;
        shortest_size = channel_index(i,1);
    end
end
check = channel_index == 1;
for i = 1:length(check)
    if check(i) == 1 && correct(1,1,i) == 0 && correct(2,1,i) == 0 && correct(3,1,i) == 0 && correct(4,1,i) == 0
        
    end
end
totals = transpose(squeeze(sum(channels)));
[getzeros(:,1), getzeros(:,2)] = find(~totals);
if getzeros(1,2) == 1
    status = ['Unable to find a correct value for channel ', num2str(getzeros(1,1))];
    error(status);
else
    short_channel.num = getzeros(1,1);
    short_channel.length = getzeros(2,1) - 1;
end