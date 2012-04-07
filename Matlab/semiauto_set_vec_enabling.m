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


function semiauto_set_vec_enabling(handles)

% if switching to automatic mode, unselect all
if get(handles.radiobutton_vec_manual, 'Value')
    vec_adjustments_visible(handles, 'on');

    % enable the vectorized cell adjustments
    names = fieldnames(handles);
    for i = 1:length(names)
        cont = strfind(names{i}, 'vec_');
        if ~isempty(cont) && cont(1) == 1
            set(handles.(names{i}), 'Enable', 'on')
        end
        cont = strfind(names{i}, 'button_refine_');
        if ~isempty(cont) && cont(1) == 1
            set(handles.(names{i}), 'Enable', 'on')
        end
    end

    set(handles.vec_activate_cell, 'String', 'Activate cell');
    set(handles.vec_activate_cell, 'Enable', 'on');

%     set(handles.vec_activate_cell, 'Enable', 'off');    
%     [T Z] = getTZ(handles);
%     for i = 1:length(handles.activeCell)
%         if handles.embryo.isTrackingCandidate(handles.activeCell(i), T, Z)
%             set(handles.vec_activate_cell, 'Enable', 'on');
%         end
%     end
    
else
    handles.activeCell = [];
    handles.activeVertex = [];
    set(handles.vec_add_cell, 'Enable', 'off');
    set(handles.vec_remove_cell, 'Enable', 'off');
    set(handles.vec_move_vertex, 'Enable', 'off');
    set(handles.vec_remove_vertex, 'Enable', 'off');
    set(handles.vec_puncture_cell, 'Enable', 'off');
    
    set(handles.vec_activate_cell, 'Enable', 'on');
    set(handles.vec_activate_cell, 'String', 'R+S+A edge');
end

% this is screwy-- should only add cells by adding edges
% it doesn't work because if i cut into a cell to add a new one, the
% vertices of that existing cell don't get updated. basically, this
% function does not take into account the effects it has on existing cells,
% but just throws a new one in the mix. AddEdge does this properly with no
% problems
% set(handles.vec_add_cell, 'Enable', 'off');