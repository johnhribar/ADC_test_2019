function [volt_channel_1, std_dev_1, volt_channel_2, std_dev_2] = calAvgVolt(multimeter, samples)

sample_str = ['SAMPle:COUNt ', num2str(samples)];

fprintf(multimeter, 'CONFigure:VOLTage:DC AUTO, DEF, (@FRONt1)');
fprintf(multimeter, sample_str);
fprintf(multimeter, 'CALCulate:FUNCtion AVERage');
fprintf(multimeter, 'CALCulate:STATe ON');
fprintf(multimeter, 'INITiate');
% pause(samples*0.25)
volt_channel_1 = str2double(query(multimeter, 'CALCulate:AVERage:AVERage?'));
std_dev_1 = str2double(query(multimeter, 'CALCulate:AVERage:SDEV?'));
fprintf(multimeter, 'CALCulate:STATe OFF');

fprintf(multimeter, 'CONFigure:VOLTage:DC AUTO, DEF, (@FRONt2)');
fprintf(multimeter, sample_str);
fprintf(multimeter, 'CALCulate:FUNCtion AVERage');
fprintf(multimeter, 'CALCulate:STATe ON');
fprintf(multimeter, 'INITiate');
% pause(samples*0.25)
volt_channel_2 = str2double(query(multimeter, 'CALCulate:AVERage:AVERage?'));
std_dev_2 = str2double(query(multimeter, 'CALCulate:AVERage:SDEV?'));
fprintf(multimeter, 'CALCulate:STATe OFF');