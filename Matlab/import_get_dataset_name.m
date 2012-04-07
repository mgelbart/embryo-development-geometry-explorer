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


function [data_set] = import_get_dataset_name(src)

% get the name of the directory
slash_loc = strfind(src, filesep);
slash_loc = slash_loc(end);
actual_dirname = src(slash_loc+1:end);
prompt = {'Enter a name for this data set:'};
dlg_title = 'Data set name';
num_lines = 1;
defaultanswer = {actual_dirname};
options.Resize='on';
options.WindowStyle='normal';
    

while 1   % until you pick an ok name
    data_set = inputdlg(prompt, dlg_title, num_lines, defaultanswer, options);
    if isempty(data_set)
        return
    end
    data_set = data_set{1};

    foldername = fullfile('..', 'DATA_GUI', data_set);
    if exist(foldername, 'dir')
        res = questdlg('A data set with this name already exists. Do you want to replace it?', ...
            'Name already exists', 'Overwrite', 'Change name', 'Cancel', 'Overwrite');
        switch res
            case 'Overwrite'
                res2 = questdlg('Are you sure? All previous data will be deleted immediately.', ...
                    'Are you sure?', 'Yes', 'Cancel', 'Yes');
                switch res2
                    case 'Yes'
                        rmdir(foldername, 's'); % 's' removes subdirectories, contents
                        rmdir(fullfile('..', 'DATA_SEMIAUTO', data_set), 's');
                        % it will all be overwritten anyway
                        break;
                    case 'No'
                        continue;
                end
            case 'Change name'
                continue;
            case 'Cancel'
                data_set = [];
                return;
        end
    else
        break;
    end
end