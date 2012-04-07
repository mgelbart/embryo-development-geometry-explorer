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


% Used for changing data sets both in EDGE and semiauto. Does everything 
% that is common to both interfaces. Generally called
% by either clear_data_set_maingui or clear_data_set_semiauto.

function handles = clear_data_set_both(handles)

% find all the other channels that are not Membranes
handles.channelnames = get_folder_names(handles.src.parent);
handles.channelnames(strcmp(handles.channelnames, 'Membranes')) = [];
handles.channelnames(strcmp(handles.channelnames, 'Measurements')) = [];



% if only 1 other channel, set the name of that checkbox to be that
if length(handles.channelnames) == 1
    set(handles.cbox_other, 'String', handles.channelnames{1});
    set(handles.cbox_other, 'Enable', 'on'); 
elseif length(handles.channelnames) > 1
    set(handles.cbox_other, 'String', 'Other channels');
    set(handles.cbox_other, 'Enable', 'on'); 
else
    set(handles.cbox_other, 'Enable', 'off');
end


handles = handles_set_channelsrc_paths(handles);

% all the channels that have ever been exported
% used in slider_callbacks_draw_image_slice
handles.all_channelnames = get_folder_names(fullfile('..', 'Measurements'));

handles.activeChannels = [];

% is the data set fixed?
handles.fixed = isnan(handles.info.seconds_per_frame);


% the name of the function that gives the filename for an image
cd(handles.src.membranes);
handles.info.image_file = @image_filename;
% handles.info.image_file.raw = @(t, z) double(imread(image_filename(t, z, handles.src.raw)));
% handles.info.image_file.bord= @(t, z) double(imread(image_filename(t, z, handles.src.bord)));
handles.info.channel_image_file = cell(length(handles.channelnames));
for i = 1:length(handles.channelnames)
    cd(handles.src.channelsrc{i});
    handles.info.channel_image_file{i} = @image_filename;
%     handles.info.channel_image_file{i} = @(t, z) double(imread(image_filename(t, z, handles.src.channelsrc{channelnum})));
end
cd(fullfile(handles.program_dir, 'Matlab'));

% clear current axes
cla(handles.axes1);

% set the size of the axes
set(handles.axes1, 'XLim', [1 handles.info.Xs]);
set(handles.axes1, 'YLim', [1 handles.info.Ys]);

% set the "data info" panel
names = fieldnames(handles.info);
for i = 1:length(names)
    name = names{i};
    button_name = strcat('info_text_', name);
    if isfield(handles, button_name)
        set(handles.(button_name), 'String', my_num2str(handles.info.(name)));
    end
end

% initialize the checkboxes
set(handles.cbox_raw,  'Value', 1);
set(handles.cbox_bord, 'Value', 0);
set(handles.cbox_poly, 'Value', 1);
set(handles.cbox_other,'Value', 0);

