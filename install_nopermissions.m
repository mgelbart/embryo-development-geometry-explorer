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


%% message to user
msgbox('Installation completed. You must restart Matlab before continuing.', ...
    'Installation successful');

