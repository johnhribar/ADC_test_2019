function alignClock(ni845x, CS, CLK0B, CH0B, alternating_line)

rising_edges_0B = clockEdge(CLK0B.vec, 'rise');
falling_edges_0B = clockEdge(CLK0B.vec, 'fall');
signal_edges = clockEdge(CH0B.vec(alternating_line,:),'rise');

rising_diffB = rising_edges_0B(1:75) - signal_edges(1:75);
rising_diffB = round(mean(rising_diffB));
falling_diffB = falling_edges_0B(1:75) - signal_edges(1:75);
falling_diffB = round(mean(falling_diffB));

ideal_offset = ceil((rising_diffB - falling_diffB) / 2);

if rising_diffB == ideal_offset
    delay = 0;
elseif rising_diffB < ideal_offset && rising_diffB > 0
    delay = ceil(ideal_offset - rising_diffB);
elseif rising_diffB == 0 || rising_diffB == -1  %% could also be for -2 depending on if its better to sample earlier or later
    delay = ideal_offset;
elseif rising_diffB < -1 || rising_diffB > ideal_offset
    delay = ceil(ideal_offset - falling_diffB);
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

writeNi845x(ni845x, CS, '0065', data);