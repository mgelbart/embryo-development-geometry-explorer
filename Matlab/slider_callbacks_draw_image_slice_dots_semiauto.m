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


function handles = slider_callbacks_draw_image_slice_dots_semiauto(handles)
% the draw_image_slice function is now split into two. this one deals with
% when you click on cells or vertices-- it just plots the dots as
% necessary, without replotting the rest of handles.axes1.


axes(handles.axes1);
hold on


try  % delete previous centroids
    delete(handles.cents_handle);
end
try  % delete previous vertices
    delete(handles.verts_handle);
end

% draw centroids of active Cells
if ~isempty(handles.activeCell)
    % make a javaarray
%     activecells = javaArray('Cell', length(handles.activeCell));
%     for i = 1:length(handles.activeCell)
%         activecells(i) = handles.activeCell{i};
%     end

    [T Z] = getTZ(handles);
    activecells = handles.embryo.getCells(handles.activeCell, T, Z);
    cents = Cell.centroidStack(activecells);
    handles.cents_handle = plot(cents(:,2), cents(:,1), '.r');  
    
    verts = Cell.vertexCoords(activecells);
    handles.verts_handle = plot(verts(:,2), verts(:,1), '.b');  %'MarkerSize', 15
    
    % plot the vertices of these cells
%     for i = 1:length(activecells)
%         verts = Vertex.coords(activecells(i).vertices);
%         handles.verts_handle = plot(verts(:,2), verts(:, 1), '.r');
%     end
end



% for semiauto, draw vertices
if isfield(handles, 'activeVertex')
    if ~isempty(handles.activeVertex)
        % make a javaarray
        activeverts = javaArray('Vertex', length(handles.activeVertex));
        for i = 1:length(handles.activeVertex)
            activeverts(i) = handles.activeVertex{i};
        end
        verts = Vertex.coords(activeverts);
        handles.verts_handle = plot(verts(:,2), verts(:, 1), '.b');
    end
end
