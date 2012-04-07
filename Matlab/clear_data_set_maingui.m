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


% Used for changing data sets in EDGE. Only does tasks specific to EDGE,
% i.e., those that don't apply in semiauto such as 3D renderings.

function handles = clear_data_set_maingui(handles, data_set)

set(handles.text_readyproc, 'Visible', 'on');
set(handles.text_readyproc, 'String', 'Loading...');
set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
drawnow;

handles.is_maingui = 1;
handles.is_semiauto = 0;

%%%% get data info
info = read_data_info(data_set);

if info.notfound  % if this is a new data set, never been imported
    msgbox(strcat('Info for data set "', data_set, ...
        '" does not exist. Data set must first be processed using semiauto.m'), ...
        'Loading failed', 'error'); 
    set(handles.text_readyproc, 'Visible', 'off');
    % put the dropdown back to its old value
    all_datasets = get(handles.dropdown_datasets, 'String');
    old_dataset_number = find(strcmp(all_datasets, handles.data_set));
    set(handles.dropdown_datasets, 'Value', old_dataset_number);   
    return;
end

handles.data_set = data_set;
handles.info = info;

handles.activeCellNeighbors = cell(0);
% handles.neighbors_handle = [];
% handles.cents_handle = [];

% set the source paths
handles = handles_set_program_dir(handles);
handles = handles_set_src_paths(handles);

handles = clear_data_set_both(handles);  % does most of the jobs

% these 2 items are kept in separate mat files for now --
% might want to put them back together at some point?
if exist(fullfile(handles.src.parent, 'embryo_data.mat'), 'file')
    load(fullfile(handles.src.parent, 'embryo_data'));
    handles.embryo = embryo4d;
    clear embryo4d;
else
    % this might not be the right thing to do in this situation --
    % it's a slight different situation from info.notfound in that there
    % exists an entry in DATA_INFO, they just never did Export to EDGE
    msgbox(strcat('Cannot find file ', strcat(handles.src.parent, 'embryo_data.mat'), ...
        '. Data set must first be processed using semiauto.m'), 'Loading failed', 'error');
    set(handles.text_readyproc, 'Visible', 'off');
    return;
end


% CONSISTENCY check: make sure that the data info matches that of the
% embryo. this can be a problem  if you change something in semiauto but
% don't re-export
if handles.info.start_time ~= handles.embryo.startTime || ...
        handles.info.end_time ~= handles.embryo.endTime || ...
        handles.info.master_time ~= handles.embryo.masterTime || ...
        handles.info.bottom_layer ~= handles.embryo.bottomLayer || ...
        handles.info.top_layer ~= handles.embryo.topLayer || ...
        handles.info.master_layer ~= handles.embryo.masterLayer
   msgbox(strcat('Information in DATA_INFO.csv does not match informaton stored in the embryo object.', ...
       'DATA_INFO may have been changed without this data set being re-exported to EDGE.', ...
       'Exporting this data set from semiauto to EDGE may solve the problem'), 'Loading failed', 'error');
   set(handles.text_readyproc, 'Visible', 'off');
   return;
end


% just write this once in case I want to change this list
% handles.builtin = {'Area'; 'Perimeter'; 'Centroid-x'; 'Centroid-y'};

% initialize the measurements dropdown menu and load stored_properties
% measures = get_measurement_names(handles);
% allmeasures = handles.builtin;

% get the names of all the saved files
saved = dir(handles.src.measurements);
goodnames = cell(0);
for i = length(saved):-1:1
   [dummy, name, ext] = fileparts(saved(i).name); 
    if strcmp(ext, '.mat')
       good = name;
%        good(good == '-') = ':';
       goodnames{end+1, 1} = good;
    end
end
% allmeasures = [allmeasures; goodnames];
allmeasures = goodnames(end:-1:1);


%%%% we no longer save things in one big file...
%%%% in fact we do not load anything at this point, we just load things as
%%%% they are needed and then if they are needed again they are already
%%%% loaded, i think that makes mnore sense than re-loading every time
%%%% although both options are reasonable at this point
% prop_filename = fullfile(handles.src.parent, 'measurements.mat');
% if exist(prop_filename, 'file')
%     load(prop_filename);
%     handles.stored_properties = stored_properties;
%     clear stored_properties;
%     channels = fieldnames(handles.stored_properties);
%     for i = 1:length(channels)
%         measures = fieldnames(handles.stored_properties.(channels{i}));
%         for j = 1:length(measures)
%             names = handles.stored_properties.(channels{i}).(measures{j}).names;
% 
%             new_names = strcat(channels{i}, '::', measures{j}, '::', names);
%             allmeasures = [allmeasures; new_names(:)];
%         end
%     end
% else
%     handles.stored_properties = [];
% end
set(handles.dropdown_measurements, 'String', allmeasures);
handles.allmeasures = allmeasures; % save for exporting
DEFAULT_MEASURE = 1;
set(handles.dropdown_measurements, 'Value', DEFAULT_MEASURE);


% if only 1 other channel, set the name of that checkbox to be that
if length(handles.channelnames) == 1
    set(handles.cbox_show_other_channels, 'String', handles.channelnames{1});
    set(handles.cbox_show_other_channels, 'Enable', 'on'); 
elseif length(handles.channelnames) > 1
    set(handles.cbox_show_other_channels, 'String', 'Other channels');
    set(handles.cbox_show_other_channels, 'Enable', 'on'); 
else
    set(handles.cbox_show_other_channels, 'Enable', 'off'); 
end
set(handles.cbox_show_other_channels, 'Value', 0); 

% initialize sliders
handles = initialize_tz_sliders(handles);

set(handles.radiobutton_3d_spatial, 'Value', 1);
% initialize movie button
if handles.fixed
    set(handles.button_make_movie, 'Enable', 'off');%'String', 'take picture');
    set(handles.movie_fps_text, 'Visible', 'off');
    set(handles.movie_fps, 'Visible', 'off');
    set(handles.radiobutton_3d_spatial, 'Enable', 'off');
    set(handles.radiobutton_3d_temporal, 'Enable', 'off');
else
    set(handles.button_make_movie, 'Enable', 'on');
    set(handles.movie_fps_text, 'Visible', 'on');
    set(handles.movie_fps, 'Visible', 'on')
    set(handles.panel_3d_z_or_t, 'Visible', 'on');
    set(handles.radiobutton_3d_spatial, 'Enable', 'on');
    set(handles.radiobutton_3d_temporal, 'Enable', 'on');
end


% some housekeeping for fixed/live data sets
if ~isnan(handles.info.seconds_per_frame) 
% times series data set
    set(handles.smoothing_panel, 'Visible', 'on');
%     set(handles.export_panel, 'Visible', 'on');
%     set(handles.radiobutton_export_this_layer, 'Value', 1);
%     set(handles.radiobutton_export_all_layers, 'Value', 0);
%     handles.export_all_layers = 0;
%     handles.exporting = 0;
else
% fixed data set
    set(handles.button_smoothed, 'Value', 1);
%     set(handles.button_high_frequency, 'Value', 0);
%     set(handles.button_rate_of_change, 'Value', 0);
%     set(handles.smoothing_panel, 'Visible', 'off');
    set(handles.smoothing_strength_slider, 'Value', 0);
    set(handles.smoothing_strength_text, 'String', '0');
%     set(handles.export_panel, 'Visible', 'off');
end


% smoothing is always off for now!
set(handles.smoothing_panel, 'Visible', 'off');



% initialize with empty struct
handles.loaded_measurements = struct;

% load in the current measurements
big_measure_name = handles.allmeasures{DEFAULT_MEASURE};
% big_measure_name(big_measure_name == ':') = '-';
load(fullfile(handles.src.measurements, [big_measure_name '.mat']));  % loads 'data', 'name', 'unit'
handles.loaded_measurements.(genvarname(big_measure_name)).data = data;
handles.loaded_measurements.(genvarname(big_measure_name)).name = name;
handles.loaded_measurements.(genvarname(big_measure_name)).unit = unit;


% clear current Cell
handles = clear_cell(handles);

% initial draw
% handles = slider_callbacks(handles, [1 1 1]);
handles = slider_callbacks_draw_image_slice(handles);
slider_callbacks_draw_measurement(handles);
slider_callbacks_draw_3D_cell(handles);

fprintf('Data Set "%s" loaded.\n', handles.data_set);
% set(handles.text_readyproc, 'String', 'Ready');
% set(handles.text_readyproc, 'ForegroundColor', [0 1 0]);
% drawnow;
set(handles.text_readyproc, 'Visible', 'off');