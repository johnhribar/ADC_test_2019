function [CLK0A, CLK0B] = getClock(LA, run_update)
if run_update
    LA.hConnect.Run()
    LA.hConnect.WaitComplete(int32(15))
end
[LA.CLK0A, size_0A] = LA.CLK0A.BusSignalData.GetDataBySample...
    (LA.CLK0A.BusSignalData.StartSample,...
    LA.CLK0A.BusSignalData.EndSample, 3);
[LA.CLK0B, size_0B] = LA.CLK0B.BusSignalData.GetDataBySample...
    (LA.CLK0B.BusSignalData.StartSample,...
    LA.CLK0B.BusSignalData.EndSample, 3);
numLines = 1;
CLK0B.str = dec2bin(LA.CLK0B, numLines);
CLK0B.str = CLK0B.str';
CLK0B.str = flipud(CLK0B.str);
CLK0B.vec = zeros(numLines,size_0B);
for i = 1:numLines
    for j = 1:size_0B
        switch CLK0B.str(i,j)
            case '1'
                CLK0B.vec(i,j) = 1;
            case '0'
                CLK0B.vec(i,j) = 0;
        end
    end
end

CLK0A.str = dec2bin(LA.CLK0A, numLines);
CLK0A.str = CLK0A.str';
CLK0A.str = flipud(CLK0A.str);
CLK0A.vec = zeros(numLines,size_0A);
for i = 1:numLines
    for j = 1:size_0A
        switch CLK0A.str(i,j)
            case '1'
                CLK0A.vec(i,j) = 1;
            case '0'
                CLK0A.vec(i,j) = 0;
        end
    end
end
end

