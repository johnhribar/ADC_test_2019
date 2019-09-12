function channels = getChannels(LA, run_update)
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
CH_B.str = dec2bin(LA.CH0B, numLines);
CH_B.str = CH_B.str';
CH_B.str = flipud(CH_B.str);
CH_B.vec = zeros(numLines,size_0B);
for i = 1:numLines
    for j = 1:size_0B
        switch CH_B.str(i,j)
            case '1'
                CH_B.vec(i,j) = 1;
            case '0'
                CH_B.vec(i,j) = 0;
        end
    end
end
CH_A.str = dec2bin(LA.CH0A, numLines);
CH_A.str = CH_A.str';
CH_A.str = flipud(CH_A.str);
CH_A.vec = zeros(numLines,size_0A);
for i = 1:numLines
    for j = 1:size_0A
        switch CH_A.str(i,j)
            case '1'
                CH_A.vec(i,j) = 1;
            case '0'
                CH_A.vec(i,j) = 0;
        end
    end
end

channels(:,:,1) = CH_A.vec(1:4,:);
channels(:,:,2) = CH_A.vec(5:8,:);
channels(:,:,3) = CH_A.vec(9:12,:);
channels(:,:,4) = CH_B.vec(1:4,:);
channels(:,:,5) = CH_B.vec(5:8,:);
channels(:,:,6) = CH_B.vec(9:12,:);
