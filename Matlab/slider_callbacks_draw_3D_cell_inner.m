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


function slider_callbacks_draw_3D_cell_inner(handles, T, Z, cellind)




% gets an array of cells making a "cell stack"
dx = handles.info.microns_per_pixel;
if get(handles.radiobutton_3d_spatial, 'Value')
    cell_stack = handles.embryo.getCellStack(cellind, T);
    zlabel 'z (microns)';
    dz = handles.info.microns_per_z_step;
    slice_highlight = abs(Z - handles.info.bottom_layer) + 1;
    % add 1 to match with matlab array indexing
else
    cell_stack = handles.embryo.getCellStackTemporal(cellind, Z);
    zlabel 't (minutes)';
    dz = handles.info.seconds_per_frame / 60;
    slice_highlight = abs(T - handles.info.start_time) + 1;
% add 1 to match with matlab array indexing
end



draw_cell_stack_highlight_z(cell_stack, T, slice_highlight, handles, dx, dz);


% draw all the neighbors as well
if ~isempty(handles.activeCellNeighbors) %&& get(handles.neighbors_3d, 'Value')
    for i = 1:length(handles.activeCellNeighbors)
        for j = 1:length(handles.activeCellNeighbors{i})
            cell_stack = handles.embryo.getCellStack(handles.activeCellNeighbors{i}(j), T);
            draw_cell_stack_highlight_z(cell_stack, T, Z,handles, dx, dz);
        end
    end
end
