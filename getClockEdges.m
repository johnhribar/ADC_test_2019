function [CH0A, CH0B, clock_edges, clock, clk_str] = getClockEdges(ni845x, CS,...
    LA, CLK0A, CLK0B, CH0A, alternating_line, sample_ratio, cycle, adc)

if adc == 1
    CSA = CS.RC0A;
    CSB = CS.RC0B;
else
    CSA = CS.RC1A;
    CSB = CS.RC1B;
end

clock_edges_0A = clockEdge(CLK0A.vec, 'risefall');
signal_edges = clockEdge(CH0A.vec(alternating_line,:),'risefall');
diffA = clock_edges_0A(1:100) - signal_edges(1:100);
diffA = round(mean(diffA));
if diffA > 0
    diffA = diffA - round(sample_ratio);
end
diffA = abs(diffA);
while diffA > 3
    clock_edges_0B = clockEdge(CLK0B.vec, 'risefall');
    diffB = clock_edges_0B(1:100) - signal_edges(1:100);
    diffB = round(mean(diffB));
    if diffB > 0
        diffB = diffB - round(sample_ratio);
    end
    diffB = abs(diffB);
    if diffB <= 3
        data = diffB * 1280 + 64;
        data = dec2hex(data,4);
        cs = CSB;
        clock = 'B';
        break;
    else
        diffA = 3;
        warning('Neither clock aligns. Hoping for the best')
    end
end
if diffA <= 3
    data = diffA * 1280 + 64;
    data = dec2hex(data,4);
    cs = CSA;
    clock = 'A';
end
writeNi845x(ni845x, cs, '0065', data);
[CH0A, CH0B] = update(LA, true);
first_12 = first12(CH0A.vec, cycle);
[CLK0A, CLK0B] = getClock(LA, false);
if strcmp(clock, 'A')
    if CLK0A.vec(first_12) == 1 && CLK0A.vec(first_12-1) == 0
        clk_str = 'fall';
    elseif CLK0A.vec(first_12) == 0 && CLK0A.vec(first_12-1) == 1
        clk_str = 'rise';
    else
        status = ['Using Clock ', clock];
        disp(status)
        prompt = 'Please input rise or fall: ';
        clk_str = input(prompt, 's');
    end
    clk_vec = CLK0A.vec;
else
    if CLK0B.vec(first_12) == 1 && CLK0B.vec(first_12-1) == 0
        clk_str = 'fall';
    elseif CLK0B.vec(first_12) == 0 && CLK0B.vec(first_12-1) == 1
        clk_str = 'rise';
    else
        status = ['Using Clock ', clock];
        disp(status)
        prompt = 'Please input rise or fall: ';
        clk_str = input(prompt, 's');
    end
    clk_vec = CLK0B.vec;
end
clock_edges = clockEdge(clk_vec, clk_str);
