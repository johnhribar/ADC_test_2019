close all;

for i = 1:12
    subplot(3,4,i);
    plot(clocked_signal(i,1:24))
    ylim([-1 2])
end

figure
for i = 1:4
    subplot(2,2,i);
    plot(clocked_signal(i,1:24),':*')
    ylim([-1 2])
end
figure
for i = 5:8
    subplot(2,2,i-4);
    plot(clocked_signal(i,1:24),':*')
    ylim([-1 2])
end
figure
for i = 9:12
    subplot(2,2,i-8);
    plot(clocked_signal(i,1:24),':*')
    ylim([-1 2])
end