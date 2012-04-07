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


function handles = initialize_tz_sliders(handles)


% if handles.info.bottom_layer ~= handles.info.top_layer
    % set the text for z
    start_layer = abs(handles.info.master_layer - handles.info.bottom_layer);
    set(handles.z_slider, 'Value', start_layer);
    set(handles.z_text, 'String', num2str(handles.info.master_layer));

    % set the step values
    z_max = abs(handles.info.bottom_layer - handles.info.top_layer);
    
if handles.info.bottom_layer ~= handles.info.top_layer
    set(handles.z_slider, 'SliderStep', [1/z_max; 1/z_max]); 
    set(handles.z_slider, 'Max', z_max);
    set(handles.z_slider, 'Min', 0);
    
%     set(handles.z_slider, 'Enable', 'on');
else
    set(handles.z_slider, 'SliderStep', [0; 0]);
    set(handles.z_slider, 'Max', 1);
    set(handles.z_slider, 'Min', 0);
    
%     set(handles.z_slider, 'Enable', 'off');
end
   
    
%     set(handles.z_slider, 'Visible', 'on');
%     set(handles.z_text_label, 'Visible', 'on');
%     set(handles.z_text, 'Visible', 'on');
% else
    % data set with only one layer
%     set(handles.z_slider, 'Visible', 'off');
%     set(handles.z_text_label, 'Visible', 'off');
%     set(handles.z_text, 'Visible', 'off');
% end

% turn temporal slider off if fixed data set
if ~handles.fixed
    % set the text for t
    start_time = abs(handles.info.master_time - handles.info.start_time);
    set(handles.t_slider, 'Value', start_time);
    set(handles.t_text, 'String', num2str(handles.info.master_time));
    
    % times series data set
    set(handles.t_slider, 'Visible', 'on');
    set(handles.t_text_label, 'Visible', 'on');
    set(handles.t_text, 'Visible', 'on');
    
    t_max = handles.info.end_time - handles.info.start_time;
    set(handles.t_slider, 'Max', t_max);
    set(handles.t_slider, 'Min', 0);
    set(handles.t_slider, 'SliderStep', ...
        [1/t_max; 1/t_max]);
else
    % fixed data set
    set(handles.t_slider, 'Visible', 'off');
    set(handles.t_text_label, 'Visible', 'off');
    set(handles.t_text, 'Visible', 'off');
end

% need this because they are by default disabled when running a 
% new data set for the first time
set(handles.z_slider, 'Enable', 'on');
set(handles.t_slider, 'Enable', 'on');