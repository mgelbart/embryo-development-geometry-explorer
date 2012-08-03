% Install script for EDGE 
% by Michael Gelbart
clear all; clc;

% ***user-defined *** %
JAVA_NAME = fullfile('java1', 'bin');
MATLAB_NAME = 'Matlab';
MEASUREMENTS_NAME = 'Measurements';
JAVA_MEMORY_STRING = '-Xmx512m';
% ******************* %

% get the path to this file
[program_dir] = fileparts(mfilename('fullpath'));


%% add the Measurements and Matlab folders to the path
matlab_path = fullfile(program_dir, MATLAB_NAME);
measurements_path = fullfile(program_dir, MEASUREMENTS_NAME);
addpath(matlab_path, measurements_path);
savepath;


%% edit the java.opts file
root_dir = matlabroot;  % the Matlab root directory
opts_directory_location = fullfile(root_dir, 'bin', computer('arch'), 'java.opts');

fid = fopen(opts_directory_location, 'a');
% if fid < 0
%     disp(['install.m: Cannot find file ', opts_directory_location]);
%     disp('Installation aborted.');
%     return;    
% end
if fid >= 0
    fprintf(fid, '\n%s', JAVA_MEMORY_STRING);
    fclose(fid);
end

%% edit the classpath file -- NOW ADDED TO DYNAMIC PATH IN semiauto.m AND edge.m
java_path = fullfile(program_dir, JAVA_NAME);
classpath_name = fullfile(matlabroot, 'toolbox', 'local', 'classpath.txt');
fid = fopen(classpath_name, 'a');
% if fid < 0
%     disp(strcat('install.m: Cannot find file ', classpath_name));
%     disp('Installation aborted.');
%     return;
% end
if fid > 0
    fprintf(fid, '\n%s', java_path);
    fclose(fid);
end


%% message to user
msgbox('Installation completed. You must restart Matlab before continuing.', ...
    'Installation successful');

