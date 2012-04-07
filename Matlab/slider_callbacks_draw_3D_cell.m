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


function slider_callbacks_draw_3D_cell(handles, T, Z)
% this function is used both for making movies and for general use in EDGE.
% when making movies, we want to input an arbitrary T, Z, but in general we
% just use that from handles. therefore we can do it with 1 argument
% (normal) or 3 (movies)
% (now also for drawing many cells, so there's the 4th and 5th argument)
if nargin == 1
    [T Z] = getTZ(handles);
    axes(handles.axes2);
    cla;  % clear axes
end

if isempty(handles.activeCell)% || get(handles.button_manually_select_cells, 'Value')
    return;
end

% DROPDOWN = get(handles.dropdown_measurements, 'Value');
% drop_str = get(handles.dropdown_measurements, 'String');
% MEASURE = drop_str{DROPDOWN};


 % draw 3d    
xlabel 'x (microns)'; ylabel 'y (microns)';
% title '3D reconstruction'
set(gca,'YDir','reverse')
hold on; 

for i = 1:length(handles.activeCell)
    cellind = handles.activeCell(i);

    slider_callbacks_draw_3D_cell_inner(handles, T, Z, cellind);
end

hold off;
axis equal;

% set(handles.text_readyproc, 'String', 'Ready');
% set(handles.text_readyproc, 'ForegroundColor', [0 1 0]);