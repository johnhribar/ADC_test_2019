function LA = openLA(config_file)

LA.ProgID = 'AgtLAServer.Instrument.1';
done = ['Done.' char(13)];

% Check to see that COM can be established
disp('Creating the local COM object for Logic Analyzer...')
try
    LA.hConnect = actxserver(LA.ProgID);
catch
    error('Unable to create the local COM object. Controlled abort.')
end
disp(done)

% Assigns Variables to the COM object
file_tree = 'C:\Users\testing\Desktop\ADC Testing 2019\LAConfig\';
config_file_full = [file_tree, config_file];
LA.hConnect.Open(config_file_full);  % open our pre-made configuration file
LA.modules = get(LA.hConnect, 'Modules');                                % get access to all LA modules
LA.Analyzer = get(LA.modules, 'Item', int16(0));                         % Actual analyzer is first module
LA.CH0B = get(LA.Analyzer.BusSignals, 'Item', '0B');               % Setup Channels defined in config file
LA.CH0A = get(LA.Analyzer.BusSignals, 'Item', '0A');
LA.CLK0B = get(LA.Analyzer.BusSignals, 'Item', 'CLK0B');
LA.CLK0A = get(LA.Analyzer.BusSignals, 'Item', 'CLK0A');