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


function handles = semiauto_change_image_callbacks(handles)
% resets the temp CG file every time you change the image, and other things
% should be called whenever you change what image you're looking at in
% semiauto

[T Z] = getTZ(handles);
% handles.tempcg = handles.embryo.getCellGraph(T, Z);

if isempty(handles.embryo.getCellGraph(T, Z))
    
    % disable the vectorized cell adjustments
    names = fieldnames(handles);
    for i = 1:length(names)
        cont = strfind(names{i}, 'vec_'); % if it's one of these buttons
        if ~isempty(cont) && cont(1) == 1
            set(handles.(names{i}), 'Enable', 'off')
        end
        cont = strfind(names{i}, 'button_refine_');
        if ~isempty(cont) && cont(1) == 1
            set(handles.(names{i}), 'Enable', 'off')
        end
    end
else    
    
    semiauto_set_vec_enabling(handles);
%     % enable the vectorized cell adjustments
%     names = fieldnames(handles);
%     for i = 1:length(names)
%         cont = strfind(names{i}, 'vec_');
%         if ~isempty(cont) && cont(1) == 1
%             set(handles.(names{i}), 'Enable', 'on')
%         end
%         cont = strfind(names{i}, 'button_refine_');
%         if ~isempty(cont) && cont(1) == 1
%             set(handles.(names{i}), 'Enable', 'on')
%         end
%     end
end   

% handles.activeCell = [];
% some of the indices that are slected might not be in the new image, so
% unselect those just for simplicity. also, i can only do this for _active_
% cells because inactive cells might have the same index between images but
% have nothing to do with each other
if handles.embryo.isTracked
    handles.activeCell = intersect(handles.activeCell, handles.embryo.getCellGraph(T, Z).activeCellIndices);
    if length(handles.activeCell) == 1  % fix the text
            set(handles.cell_text, 'String', num2str(handles.activeCell(1))); 
        else
            set(handles.cell_text, 'String', '-'); 
    end
else
    handles.activeCell = [];
    set(handles.cell_text, 'String', '-'); 
end
handles.activeVertex = [];


% enable/disable buttons and checkboxes as needed
if handles.embryo.isTracked
    set(handles.button_export, 'Enable', 'on');
    set(handles.cbox_inactive, 'Enable', 'on');
else
    set(handles.button_export, 'Enable', 'off');
    set(handles.cbox_inactive, 'Enable', 'off');
end
if exist(handles.info.image_file(T, Z, handles.tempsrc.bord), 'file')
    % if they have already processed that image, the file will exist
    set(handles.cbox_bord, 'Enable', 'on');
else
    set(handles.cbox_bord, 'Enable', 'off');
end
if ~isempty(handles.embryo.getCellGraph(T, Z))
    % if there is a polygon, should be same as above but i check separately 
    set(handles.cbox_poly, 'Enable', 'on');
else
    set(handles.cbox_poly, 'Enable', 'off');
end


