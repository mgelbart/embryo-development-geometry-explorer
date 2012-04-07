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


function fields = write_data_info(handles)
% writes the .csv version of data_info

data_set_name = handles.data_set;
FILENAME = fullfile('..', 'DATA_INFO.csv');

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

% get the lines literally
fid = fopen(FILENAME);
lines = textscan(fid, '%s', 'delimiter', '\n');
lines = lines{1};
fclose(fid);

for i = 1:length(labels)
    labels{i} = char(labels{i});
end

all_data_set_names = data{1};


%%%% because i don't know how to edit files, I just re-create
% the whole file (**sigh**) --> although this is not as silly if sorting
% alphabetically...
lines_fs = '%s\n';
fid = fopen(FILENAME, 'w');
fprintf(fid, lines_fs, lines{1});
fclose(fid);
fid = fopen(FILENAME, 'a');
name_fs = '%s,'; % fs = 'format string'
data_fs = repmat('%g,', 1, num_cols-1);
data_fs = strcat(data_fs(1:end-1), '\n');

success = 0;
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
        success = 1;
        fprintf(fid, name_fs, data_set_name);
        fprintf(fid, data_fs, writedata);
    else
        fprintf(fid, lines_fs, lines{i+1});
    end
end

if ~success  % if this is a new data set, we need to add an entry
    writedata = zeros(1, length(labels)-1);
    for j = 2:length(labels)  % start at 2 to skip the name
        writedata(j-1) = handles.info.(labels{j});
        fields{length(fields)+1} = labels{j};  % tells you what fields were changed (in this case, all)
    end   
    fprintf(fid, name_fs, data_set_name);
    fprintf(fid, data_fs, writedata);
end

fclose(fid);

