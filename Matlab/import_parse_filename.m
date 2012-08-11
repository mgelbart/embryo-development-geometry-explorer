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


function [name sample_file z_digits z_posn z_min z_max t_digits t_posn t_min t_max] = ...
    import_parse_filename(src, fixed)

% look for filesnames that contain a certain string
prompt = {'Only use filenames containing this string:'};
dlg_title = 'Filename contains....';
num_lines = 1;
defaultanswer = {''};
options.Resize='on';
options.WindowStyle='normal';
options.Interpreter='tex';
answer = inputdlg(prompt, dlg_title, num_lines, defaultanswer, options);
if isempty(answer) || isempty(answer{1})
    containsstring = [];
else
    containsstring = answer{1};
end

drawnow;  % because otherwise this menu doesn't go away for a while and it looks strange


 % gets the name of the first file
name = [];
files = dir(src);
for i = 1:length(files)
    if files(i).isdir
        continue;
    end

    % make sure they contain the string
    if isempty(containsstring) || ...
        ~isempty(strfind(files(i).name, containsstring)) || ...
        ~isempty(regexp(files(i).name, containsstring, 'once'))

        try  % make sure this is an image file readable by IMREAD
            imread(fullfile(src, files(i).name));
        catch
            continue;
        end

        % get the size of the first image that's read in
        name = files(i).name;
        sample_file = files(i).name;
        break;
    end
end


if isempty(name)
    msgbox('Error: could not find any images in the selected directory.', ...
        'Import failed', 'error');
    return;
end

% parse the name by finding all the numerical values
% first, find where the numbers are
nums = regexp(name, '[0-9]'); 
% the indices of the start of each number (numbers can be several
% digits long)
num_starts = nums([2 diff(nums)] > 1);

if fixed && isempty(num_starts)
    msgbox('Error: filenames of the images in this folder contain no numbers.', ...
        'Import failed', 'error')
    name = [];
    return;
end
if ~fixed && length(num_starts) <= 1
    msgbox('Error: filenames of the images in this folder do not contain 2 numbers as needed for labeling t and z in a live data set', ...
        'Import failed', 'error')
    name = [];
    return;
end

searchfor = '_z';    % look for '_z'
z_posn = NaN;
rg_z = strfind(name, searchfor);
if ~isempty(rg_z)
    rg_z = rg_z(end);  % only keep 1 (there shouldn't be more)
    % if it has a number right after the '_z'
    if ~isempty(find(num_starts == rg_z + length(searchfor), 1))
        z_posn = rg_z + length(searchfor);
    end
end

searchfor = '_t';        % look for '_t'
t_posn = NaN;
if ~fixed
    rg_t = strfind(name, searchfor);
    if ~isempty(rg_t)
        rg_t = rg_t(end);  % only keep 1 (there shouldn't be more)
        % if it has a number right after the '_t'
        if ~isempty(find(num_starts == rg_t + length(searchfor), 1))
            t_posn = rg_t + length(searchfor);
        end
    end
end


% ch_posn = NaN;
% searchfor = '_ch';    % look for '_ch'
% rg_z = strfind(name, searchfor);
% rg_z = rg_z(end);  % only keep 1 (there shouldn't be more)
% % if it has a number right after the '_ch'
% if ~isempty(find(num_starts == rg_z + length(searchfor), 1))
%     ch_posn = rg_z + length(searchfor);
% end
% 
% % if it found channels
% % wait, it should be if it found MULTIPLE channels
% if ~isnan(ch_posn)
% 
% end

% if this fails just take the best guess
% ** could make this better by looking for the number that varies!!
if fixed
    if isnan(z_posn)
        z_posn = num_starts(end);
    end
else
    if isnan(t_posn)
        t_posn = num_starts(end-1);
    end
    if isnan(z_posn)
        z_posn = num_starts(end);
    end
end





z_digits = 1;
numerical = zeros(size(name));
numerical(nums) = 1;  % a 1 wherever these a number, 0 otherwise
for i = z_posn+1:length(name)
    if numerical(i)
        z_digits = z_digits + 1;
    else
        break;
    end
end
% do the same for time in live data sets
if fixed
    t_digits = NaN;
else
    t_digits = 1;
    for i = t_posn+1 : length(name)
        if numerical(i)
            t_digits = t_digits + 1;
        else
            break;
        end
    end
end


% find the extension of sample_file. then look for images with that
% extension.
[sample_file_pathstr, sample_file_name, extension] = ...
    fileparts(sample_file);
% dot_in_string = strfind(sample_file, '.');
% dot_in_string = dot_in_string(end); % just in case 'Matlab' appears upstream in the path
% extension = sample_file(dot_in_string:end);


z_min =  Inf;
z_max = -Inf;
t_min =  Inf;
t_max = -Inf;
% find the max and min time and z

files = dir(src);
for i = 1:length(files)
    if files(i).isdir
        continue;
    end

    % make sure they contain the string
    if isempty(containsstring) || ...
        ~isempty(strfind(files(i).name, containsstring)) || ...
         ~isempty(regexp(files(i).name, containsstring, 'once'))

    % only look for files with the same extension
        [this_file_pathstr, this_file_name, this_file_ext] = fileparts(files(i).name);
        if strcmp(extension, this_file_ext)
%         if length(files(i).name) >= length(extension) && ...
%                 strcmp(files(i).name(end-length(extension)+1:end), extension)

%         try  % make sure this is an image file readable by IMREAD
%             imread(fullfile(src, files(i).name));
%         catch
%             continue;
%         end

            % get the size of the first image that's read in
            this_name = files(i).name;

            this_z = str2double(this_name(z_posn : z_posn + z_digits - 1));
            z_min = min(z_min, this_z);
            z_max = max(z_max, this_z);

            if ~fixed
                this_t = str2double(this_name(t_posn : t_posn + t_digits - 1));
                t_min = min(t_min, this_t);
                t_max = max(t_max, this_t);           
            end
        end
    end
end
if fixed
    t_min = NaN;
    t_max = NaN;
end


