function [powerSupply, multimeter] = openInstruments()
% Find GPIB objects.
powerSupply = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 23, 'Tag', '');
multimeter = instrfind('Type', 'gpib', 'BoardIndex', 0, 'PrimaryAddress', 22, 'Tag', '');

% Create the GPIB objects if they do not exist
% otherwise use the objects that were found.
if isempty(powerSupply)
    powerSupply = gpib('NI', 0, 23);
else
    fclose(powerSupply);
    powerSupply = powerSupply(1);
end

if isempty(multimeter)
    multimeter = gpib('NI', 0, 22);
else
    fclose(multimeter);
    multimeter = multimeter(1);
end
% Connect to instrument objects.
fopen(powerSupply);
fopen(multimeter);

%% Instrument Configuration and Control
% 
% % Communicating with instrument object, obj1.
% fprintf(powerSupply, '%c\n', 'OUTPut ON');
% fprintf(powerSupply, '%c\n', 'OUTPut OFF');
% fprintf(powerSupply, '%c\n', 'VOLTage 2.5');
% fprintf(powerSupply, '%c\n', 'VOLTage 0');

% data1 = query(multimeter, 'MEASure?');
% data4 = query(multimeter, 'MEASure:VOLTage:DC? AUTO, MAX, (@FRONt2)');
% data2 = query(multimeter, 'MEASure:DIFFerence?');

end