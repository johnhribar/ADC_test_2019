function edges = clockEdge(clock, edge_str)

n = 1;
edges = zeros(2, length(clock));
for i = 2:length(clock)
    if (clock(i) == 1 && clock(i-1) == 0) && (strcmp(edge_str, 'rise') || strcmp(edge_str, 'risefall'))
        edges(1,n) = i;
        n = n + 1;
    end
    if (clock(i) == 0 && clock(i-1) == 1) && (strcmp(edge_str, 'fall') || strcmp(edge_str, 'risefall'))
        edges(1,n) = i;
        n = n + 1;
    end
end
edges = edges(edges ~= 0);
