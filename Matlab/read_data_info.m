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


function info = read_data_info(data_set_name)
% reads the CSV version of data_info for data_set_name
% if the data set is not foumd, it returns an empty array

FILENAME = fullfile('..', 'DATA_INFO.csv');
% assumes the first column is the name and the rest are
% numerical values

% count the number of columns by counting the number of commas in the first
% row and adding 1 (because # columns = # commas + 1)
fid = fopen(FILENAME);
count_commas = textscan(fid, '%s', 1);
count_commas = count_commas{1};
count_commas = count_commas{1};
num_cols = sum(count_commas == ',') + 1;
fclose(fid);

% get the labels and all the data
labels_format_string =              repmat('%s', 1, num_cols);
data_format_string   = strcat('%s', repmat('%n', 1, num_cols-1));

fid = fopen(FILENAME);
labels = textscan(fid, labels_format_string, 1, 'delimiter', ',');  % the 1 means just read this 1 time
data = textscan(fid, data_format_string, 'delimiter', ','); 
fclose(fid);


for i = 1:length(labels)
    labels{i} = char(labels{i});
end

all_data_set_names = data{1};

info = [];
for i = 1:length(all_data_set_names)
    if strcmp(all_data_set_names{i}, data_set_name)
        % create the "info" structure
%         info = struct(labels);
        info = cell2struct(cell(length(labels), 1), labels, 1);
        for j = 2:length(labels)  % start at 2 to skip the name
            if iscell(data{j})
                % this should never happen
                info.(labels{j}) = data{j}{i};
            else
                info.(labels{j}) = data{j}(i);
            end
        end
        break;
    end
end

      
dummy_val = NaN;
% if didn't find anything, fill the fields with a dummy val
if isempty(info)
    for j = 2:length(labels)
        info.(labels{j}) = dummy_val;
    end
    info.notfound = 1;
else
    info.notfound = 0;
end
    

