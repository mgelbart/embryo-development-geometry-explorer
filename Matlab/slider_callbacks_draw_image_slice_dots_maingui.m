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


function handles = slider_callbacks_draw_image_slice_dots_maingui(handles)
% the draw_image_slice function is now split into two. this one deals with
% when you click on cells or vertices-- it just plots the dots as
% necessary, without replotting the rest of handles.axes1.


% note: i used try and catch here, which is a bit sloppy but works well.
% alternatively i could split the centroid and vertex plotting into two
% functions and be careful which one i am calling
axes(handles.axes1);
hold on

% need to make neighbors_handle an array because of the colors problem.
% basically i want to define the color of each cell based on its index,
% so i need to do separate plot statements. i don't know how to make
% just one handle out of a bunch of separate plot statements, so i'm
% just storing all the handles separately. the point of all this in the
% first place is that we can delete the handles this way and then we
% can get rid of dots quickly, instead of having to redraw the whole
% image when we want to remove dots. this is a big saving for high-res
% images that take a while to draw.

% delete previous neighbors
% handles.neighbors_handle
for i = 1:length(handles.neighbors_handle)
    delete(handles.neighbors_handle{i});
end

try  % delete previous centroids
% if ~isempty(handles.cents_handle)
    delete(handles.cents_handle);
% end
end


[T Z] = getTZ(handles);
cg = handles.embryo.getCellGraph(T, Z);


% draw centroids of active Cells
if ~isempty(handles.activeCell)
    % make a javaarray
    activecells = javaArray('Cell', length(handles.activeCell));
    if get(handles.button_manually_select_cells, 'Value')
        for i = 1:length(handles.activeCell)
            activecells(i) = cg.getCell(handles.activeCell(i));
        end
        cents = round(Cell.centroidStack(activecells));
    else
        the_cell = cg.getCell(handles.activeCell);
        if isempty(the_cell)
            return
        end
        cents = the_cell.centroidInt;
        cents = cents(:).';  % make it a row vector
    end
    if get(handles.button_manually_select_cells, 'Value'); % && ...
%             length(handles.activeCell) ~= handles.embryo.getCellGraph(T, Z).numActiveCells;
        % some sketchy code for the colors -- to make use of the default
        % ColorOrder property of the axes in matlab. definining my own
        % ColorOrder was too much trouble.
        xplot = [cents(:, 2) NaN(size(cents, 1), 1)].';
        yplot = [cents(:, 1) NaN(size(cents, 1), 1)].';
        handles.cents_handle = plot(xplot, yplot, '.');
    else
        handles.cents_handle = plot(cents(:,2), cents(:,1), '.g');
        
        % neighbors
        if ~isempty(handles.activeCellNeighbors)
            for i = 1:length(handles.activeCellNeighbors)
                
                % this is already a java array, very conveniently. so I can
                % immediately pass it inly the Cell.centroidStack(Cell[] )
                % function, unlike the mess above with manually creating a
                % javaarray
                activeneighbors = cg.getCell(handles.activeCellNeighbors{i});
                
                if ~isempty(activeneighbors)
                    cents = round(Cell.centroidStack(activeneighbors));
                    handles.neighbors_handle{i} = plot(cents(:, 2), cents(:, 1), '.', 'Color', my_colors(i+1));  % +1 to skip red because the center is already red
                end
                
            end
        end
        
    end
end