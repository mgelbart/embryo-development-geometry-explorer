%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (c) 2012, Michael Gelbart (michael.gelbart@gmail.com)
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification,
% are permitted provided that the following conditions are met:
%
% - Redistributions of source code must retain the above copyright notice,
%   this list of conditions and the following disclaimer.
% 
% - Redistributions in binary form must reproduce the above copyright notice,
%   this list of conditions and the following disclaimer in the documentation
%   and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
% LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
% ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
% EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Finds the specific measurement files for a given data set. 
% Looks in the folder measure_path, and looks for the specified channels.
% Returns measures, and array of all measurement function names, and
% measurementchannels, an array of the same size that gives the
% corresponding channel for each of the measurement names. 

function [measurechannels measures] = get_measurement_file_names_specific_ch(measure_path, channels)

current_dir = pwd;

% first, we have the built in measurements
measures = cell(0);
measurechannels = cell(0);
% now we must check what is exported
% first, loop through each subdirector in the Measurements folder
% then loop through each file and get the file names
% 


for i = 1:length(channels)
    cd(fullfile(measure_path, channels{i}));  % go in that directory
    functions = dir();
    for j = 1:length(functions)
        if functions(j).isdir
            continue;
        end
        fname = functions(j).name;
        if length(fname) <= 2
            continue;
        end
        if ~strcmp(fname(end-1:end), '.m')  % make sure it ends with '.m'
            continue;
        end
            
        function_name = functions(j).name;
        function_name = function_name(1:end-2);  % remove the .m from the end

        measures = [measures function_name];
        measurechannels = [measurechannels channels{i}];
    end
end

cd(current_dir);