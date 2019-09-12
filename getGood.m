function good_values = getGood(ni845x, LA, CS, adc, version)

good_values = testValuesUniqueAlt(ni845x, LA, CS, adc);
% good_values = testValuesAlt(ni845x, LA, CS, adc, good_values, 'FIRST');
save_str = [version, 'goodValues.mat'];
save(save_str, 'good_values');

% load_str = [version, 'goodValues.mat'];
% load(load_str, 'good_values');
% good_values = testValuesAlt(ni845x, LA, CS, adc, good_values, 'BR1');
% save_str = [version, 'goodValuesBR1.mat'];
% save(save_str, 'good_values');

% load_str = [version, 'goodValues.mat'];
% load(load_str, 'good_values');
% good_values = testValuesAlt(ni845x, LA, CS, adc, good_values, 'BR5');
% save_str = [version, 'goodValuesBR5.mat'];
% save(save_str, 'good_values');

% load_str = [version, 'goodValues.mat'];
% load(load_str, 'good_values');
% good_values = testValuesAlt(ni845x, LA, CS, adc, good_values, 'tog');
% save_str = [version, 'goodValuesTOG.mat'];
% save(save_str, 'good_values');

