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


function handles = update_embryo(handles)
% if the user changes one of the base properties in the semiauto then we
% are in trouble because we don't want to lose all of the cellgraphs
% (obviously!!) so, here's what we do......
% we make a new embryo and copy over as many of the cellgraphs as possible.
% this means if you change to a smaller range of times, and then change
% back to the larger one, you've lost the CellGraphs from this process. but
% that's ok, the user has no reason to do this


% first, check that something is actually different........
% fields = changed_data_info(handles);
% if isempty(fields)  % if there are no changes
%     return
% end
% ************************!!!!!
%IN THE END WE WILL WANT THIS, BUT FOR NOW IT'S A GOOD HACK FOR FORCING IT
%TO TRRACK


readyproc(handles, 'tracking');
new_embryo = Embryo4D(handles.embryo, ...
    handles.info.start_time, handles.info.end_time, handles.info.master_time, ...
    handles.info.bottom_layer, handles.info.top_layer, handles.info.master_layer, ... 
    handles.info.tracking_area_change_Z, handles.info.tracking_layers_back_Z, ...
    handles.info.tracking_centroid_distance_Z / handles.info.microns_per_pixel, ...
    handles.info.tracking_area_change_T, handles.info.tracking_layers_back_T, ...
    handles.info.tracking_centroid_distance_T / handles.info.microns_per_pixel);
readyproc(handles, 'ready');

handles.embryo = new_embryo;
% save_embryo(handles);

% set the sliders to the reference image
% (only want to do that if we are out of range now...)
[T Z] =  getTZ(handles);

if Z > max(handles.info.top_layer, handles.info.bottom_layer) || ...
   Z < min(handles.info.top_layer, handles.info.bottom_layer) || ...
   T > max(handles.info.start_time, handles.info.end_time) || ...
   T < min(handles.info.start_time, handles.info.end_time)    
    handles = go_to_image(handles, handles.info.master_time, handles.info.master_layer);
end

% bug when calling this from exit_embryo sometimes. dirty fix here...
try
handles = slider_callbacks_draw_image_slice(handles);
end
