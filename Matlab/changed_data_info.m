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


% Changes the metadata file DATA_INFO.CSV by updating it with the newest
% parameter values stored in handles.info
%
% Returns the set of fields in DATA_INFO.CSV that were changed by this
% update.

function fields = changed_data_info(handles)

data_set_name = handles.data_set;
FILENAME = '../DATA_INFO.csv';

fid = fopen(FILENAME);
% count the number of columns
count_commas = textscan(fid, '%s', 1);
count_commas = count_commas{1};
count_commas = count_commas{1};
num_cols = sum(count_commas == ',') + 1;
fclose(fid);

labels_format_string =              repmat('%s', 1, num_cols);
data_format_string   = strcat('%s', repmat('%n', 1, num_cols-1));
% 
fid = fopen(FILENAME);
labels = textscan(fid, labels_format_string, 1, 'delimiter', ',');  % the 1 means just read this 1 time
data = textscan(fid, data_format_string, 'delimiter', ','); 
fclose(fid);

for i = 1:length(labels)
    labels{i} = char(labels{i});
end

all_data_set_names = data{1};


% I just re-create the whole file (not ideal...) 
% --> although this is not as silly if sorting alphabetically...
fid = fopen(FILENAME);

fields = cell(0);  % tells you what fields were changed
for i = 1:length(all_data_set_names)
    if strcmp(all_data_set_names{i}, data_set_name)
        writedata = zeros(1, length(labels)-1);
        for j = 2:length(labels)  % start at 2 to skip the name
            writedata(j-1) = handles.info.(labels{j});
            if writedata(j-1) ~= data{j}(i) && ~(isnan(writedata(j-1)) && isnan(data{j}(i)))
                fields{length(fields)+1} = labels{j};
            end
        end
    else
    end
end

fclose(fid);

