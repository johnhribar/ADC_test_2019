function [delta_avg, std_dev] = calAVG(multimeter, samples)

sample_str = ['SAMPle:COUNt ', num2str(samples)];
fprintf(multimeter, 'CONFigure:VOLTage:DC:DIFFerence AUTO, DEF');
fprintf(multimeter, sample_str);
fprintf(multimeter, 'CALCulate:FUNCtion AVERage');

fprintf(multimeter, 'CALCulate:STATe ON');

fprintf(multimeter, 'INITiate');
% pause(samples*.65)
delta_avg = str2double(query(multimeter, 'CALCulate:AVERage:AVERage?'));
std_dev = str2double(query(multimeter, 'CALCulate:AVERage:SDEV?'));
fprintf(multimeter, 'CALCulate:STATe OFF');
