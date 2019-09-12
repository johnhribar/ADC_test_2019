function version = getVersion()

load('version_variables.mat', 'file_date','version_num')

current_date = date;
if strcmp(current_date, file_date)
    version_num = version_num + 1;
else
    version_num = 0;
    file_date = current_date;
end
version = [current_date, '_V', num2str(version_num)];

save('version_variables.mat', 'file_date', 'version_num')