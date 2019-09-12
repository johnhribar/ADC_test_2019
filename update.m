function [CH0A, CH0B] = update(LA, run_update)
if run_update
    LA.hConnect.Run()
    LA.hConnect.WaitComplete(int32(15))
end
[LA.CH0B, size_0B] = LA.CH0B.BusSignalData.GetDataBySample...
    (LA.CH0B.BusSignalData.StartSample,...
    LA.CH0B.BusSignalData.EndSample, 3);
[LA.CH0A, size_0A] = LA.CH0A.BusSignalData.GetDataBySample...
    (LA.CH0A.BusSignalData.StartSample,...
    LA.CH0A.BusSignalData.EndSample, 3);
numLines = 12;
CH0B.str = dec2bin(LA.CH0B, numLines);
CH0B.str = CH0B.str';
CH0B.str = flipud(CH0B.str);
CH0B.vec = zeros(numLines,size_0B);
for i = 1:numLines
    for j = 1:size_0B
        switch CH0B.str(i,j)
            case '1'
                CH0B.vec(i,j) = 1;
            case '0'
                CH0B.vec(i,j) = 0;
        end
    end
end
CH0A.str = dec2bin(LA.CH0A, numLines);
CH0A.str = CH0A.str';
CH0A.str = flipud(CH0A.str);
CH0A.vec = zeros(numLines,size_0A);
for i = 1:numLines
    for j = 1:size_0A
        switch CH0A.str(i,j)
            case '1'
                CH0A.vec(i,j) = 1;
            case '0'
                CH0A.vec(i,j) = 0;
        end
    end
end
end

