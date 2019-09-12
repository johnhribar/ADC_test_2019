function [CH0A, CH0B, clock_edges, clock, clk_str] = syncClock(ni845x, CS,...
    LA, CLK0A, CLK0B, CH0A, alternating_line, adc)

if adc == 1
    CSA = CS.RC0A;
    CSB = CS.RC0B;
else
    CSA = CS.RC1A;
    CSB = CS.RC1B;
end

clock = 'C';
rising_edges_0A = clockEdge(CLK0A.vec, 'rise');
falling_edges_0A = clockEdge(CLK0A.vec, 'fall');
rising_edges_0B = clockEdge(CLK0B.vec, 'rise');
falling_edges_0B = clockEdge(CLK0B.vec, 'fall');
signal_edges = clockEdge(CH0A.vec(alternating_line,:),'rise');

rising_diffA = rising_edges_0A(1:75) - signal_edges(1:75);
rising_diffA = round(mean(rising_diffA));
falling_diffA = falling_edges_0A(1:75) - signal_edges(1:75);
falling_diffA = round(mean(falling_diffA));

rising_diffB = rising_edges_0B(1:75) - signal_edges(1:75);
rising_diffB = round(mean(rising_diffB));
falling_diffB = falling_edges_0B(1:75) - signal_edges(1:75);
falling_diffB = round(mean(falling_diffB));

ideal_offset = ceil(rising_diffA - falling_diffA) / 2;

if rising_diffA == ideal_offset
    delay = 0;
    clk_str = 'rise';
    clock = 'A';
    cs = CSA;
elseif rising_diffA < ideal_offset && rising_diffA > 0
    delay = ceil(ideal_offset - rising_diffA);
    clk_str = 'rise';
    clock = 'A';
    cs = CSA;
elseif rising_diffA == 0 || rising_diffA == -1  %% could also be for -2 depending on if its better to sample earlier or later
    delay = ideal_offset;
    clk_str = 'rise';
    clock = 'A';
    cs = CSA;
elseif rising_diffA < -1 || rising_diffA > ideal_offset
    delay = ceil(ideal_offset - falling_diffA);
    clk_str = 'fall';
    clock = 'A';
    cs = CSA;
end

if rising_diffB == ideal_offset
    delay = 0;
    clk_str = 'rise';
    clock = 'B';
    cs = CSB;
elseif rising_diffB < ideal_offset && rising_diffB > 0
    delay = ceil(ideal_offset - rising_diffB);
    clk_str = 'rise';
    clock = 'B';
    cs = CSB;
elseif rising_diffB == 0 || rising_diffB == -1  %% could also be for -2 depending on if its better to sample earlier or later
    delay = ideal_offset;
    clk_str = 'rise';
    clock = 'B';
    cs = CSB;
elseif rising_diffB < -1 || rising_diffB > ideal_offset
    delay = ceil(ideal_offset - falling_diffB);
    clk_str = 'fall';
    clock = 'B';
    cs = CSB;
end

if strcmp(clock, 'C')
    error('This is bad, very very bad!');
end

if delay < 0 
    delay = 0;
elseif delay > 3
    delay = 3;
end

disp(delay);

switch delay
    case 0
        data = '0041';
    case 1
        data = '0541';
    case 2
        data = '0A41';
    case 3 
        data = '0F41';
end

writeNi845x(ni845x, cs, '0065', data);
[CH0A, CH0B] = update(LA, true);
[CLK0A, CLK0B] = getClock(LA, false);
if strcmp(clock, 'A')
    clk_vec = CLK0A.vec;
elseif strcmp(clock, 'B')
    clk_vec = CLK0B.vec;
end
clock_edges = clockEdge(clk_vec, clk_str);
save('diffs.mat', 'rising_diffA', 'falling_diffA', 'rising_diffB', 'falling_diffB');