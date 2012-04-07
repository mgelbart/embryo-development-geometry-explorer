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


% because i don't know how to edit files, I just re-create
% the whole file (not ideal...) --> although this is not as silly if sorting
% alphabetically...
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

