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


% Asks if you want to save changes if there are any changes.
% This function is to be called whenever you are about to leave a data set, 
% either by changing to another one or closing the GUI. 


function handles = exit_data_set_semiauto(handles)

fields = changed_data_info(handles);
% ask about unsaved changes to DATA_INFO
if ~isempty(fields)  % if there are changes
    othermsg = 'There are unsaved changes to DATA_INFO in the following fields:';
    msg2 = 'Save them now?';
    res = questdlg([othermsg fields msg2], 'Saving changes', ...
                 'Save changes', 'Discard changes', 'Save changes');  
    if strcmp(res, 'Save changes')
        write_data_info(handles);
%         othermsg = 'Successfully updated the following fields in DATA_INFO.csv:';
%         msg = [othermsg fields];
%         msgbox(msg, 'Save successful');
%         save_embryo(handles);
    elseif strcmp(res, 'Discard changes')
        % we need to save the embryo to be consistent with the old stuff,
        % so load it back in and save over
        handles.info = read_data_info(handles.data_set);
        handles = update_embryo(handles);
    end
end


% ask about unsaved changes to the embryo data
if handles.embryo.changed
    msg = 'There are unsaved changes to the Embryo data.';
    res = questdlg(msg, 'Saving changes', ...
                 'Save changes', 'Discard changes', 'Save changes');  
    if strcmp(res, 'Save changes')
        % this is the only time we call save_embryo (!!)
        readyproc(handles, 'saving');
        handles = save_embryo(handles);
    elseif strcmp(res, 'Discard changes')
        % do nothing
    end
end




