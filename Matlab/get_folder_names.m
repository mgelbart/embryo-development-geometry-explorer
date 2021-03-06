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


% Gets the names of the datasets by checking the names of the folders
% in the directory src. returns them in a cell array, which is then used
% to create the dropdown menu

function out = get_folder_names(src)


files = dir(src);  % like pwd, but much better for this application

goodfiles = zeros(length(files), 1);
% get names of the directories
for i = 1:length(files)    
    if files(i).isdir && ~strcmp(files(i).name , '.') && ~strcmp(files(i).name, '..')
        % if it's a directory but not the '.' directory
        goodfiles(i) = 1;
    end
end
goodfiles = find(goodfiles);

out = cell(length(goodfiles), 1);
for i = 1:length(out)
    out{i} = files(goodfiles(i)).name;
end


% why not this: ?  much easier.... i guess it's just preallocation
% channelnames = cell(0);
% files = dir(input_dir);  % get the channels from this data set
% for i = 1:length(files)
%     if files(i).isdir && ~strcmp(files(i).name , '.') &&
%     ~strcmp(files(i).name, '..')
%         channelnames{length(channelnames)+1} = files(i).name;
%     end
% end
