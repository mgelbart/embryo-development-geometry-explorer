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


function readyproc(handles, val)
% controls the status text box thing for semiauto


set(handles.save_datainfo, 'Visible', 'off');

set(handles.text_readyproc_details, 'Visible', 'off');

switch val
    case 'ready'
        set(handles.text_readyproc, 'String', 'Ready');
        set(handles.text_readyproc, 'ForegroundColor', [0 1 0]);
        
        set(handles.text_processing_time, 'Visible', 'off')
        set(handles.text_processing_time_label, 'Visible', 'off')
        set(handles.text_processing_layer, 'Visible', 'off')
        set(handles.text_processing_layer_label, 'Visible', 'off')
        
        set(handles.radiobutton_stop, 'Visible', 'off');
    
        set(handles.save_datainfo, 'Visible', 'on');
        
    case 'proc'
        set(handles.text_readyproc, 'String', 'Processing');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
%         set(handles.radiobutton_stop, 'Visible', 'on');       
    
    case 'proc_all'
        set(handles.text_readyproc, 'String', 'Processing');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
        if ~isnan(handles.info.seconds_per_frame)
            set(handles.text_processing_time, 'Visible', 'on')
            set(handles.text_processing_time_label, 'Visible', 'on')
        end
        
        set(handles.text_processing_layer, 'Visible', 'on')
        set(handles.text_processing_layer_label, 'Visible', 'on') 
        
        set(handles.radiobutton_stop, 'Visible', 'on');    
    
    case 'copy'
        set(handles.text_readyproc, 'String', 'Copying');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
%         set(handles.radiobutton_stop, 'Visible', 'on');    
        
    case 'copy_all'
        set(handles.text_readyproc, 'String', 'Copying');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
        if ~isnan(handles.info.seconds_per_frame)
            set(handles.text_processing_time, 'Visible', 'on')
            set(handles.text_processing_time_label, 'Visible', 'on')
        end
        
        set(handles.text_processing_layer, 'Visible', 'on')
        set(handles.text_processing_layer_label, 'Visible', 'on') 
        
        set(handles.radiobutton_stop, 'Visible', 'on');   
        
    case 'move_all'
        set(handles.text_readyproc, 'String', 'Moving');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
        if ~isnan(handles.info.seconds_per_frame)
            set(handles.text_processing_time, 'Visible', 'on')
            set(handles.text_processing_time_label, 'Visible', 'on')
        end
        
        set(handles.text_processing_layer, 'Visible', 'on')
        set(handles.text_processing_layer_label, 'Visible', 'on') 
        
        set(handles.radiobutton_stop, 'Visible', 'on');   
        
    case 'tracking'
        set(handles.text_readyproc, 'String', 'Tracking');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
%         if ~isnan(handles.info.seconds_per_frame)
%             set(handles.text_processing_time, 'Visible', 'on')
%             set(handles.text_processing_time_label, 'Visible', 'on')
%         end
%         
%         set(handles.text_processing_layer, 'Visible', 'on')
%         set(handles.text_processing_layer_label, 'Visible', 'on') 
        
    case 'calculating'
        set(handles.text_readyproc, 'String', 'Calculating');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
        if ~isnan(handles.info.seconds_per_frame)
            set(handles.text_processing_time, 'Visible', 'on')
            set(handles.text_processing_time_label, 'Visible', 'on')
        end
        
        set(handles.text_processing_layer, 'Visible', 'on')
        set(handles.text_processing_layer_label, 'Visible', 'on') 
        
        set(handles.radiobutton_stop, 'Visible', 'on'); 

        
    case 'finalizing'
        set(handles.text_readyproc, 'String', 'Finalizing');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
        if ~isnan(handles.info.seconds_per_frame)
            set(handles.text_processing_time, 'Visible', 'on')
            set(handles.text_processing_time_label, 'Visible', 'on')
        end
        
        set(handles.text_processing_layer, 'Visible', 'on')
        set(handles.text_processing_layer_label, 'Visible', 'on') 

    case 'refining'
        set(handles.text_readyproc, 'String', 'Refining');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
    case 'refine_all'
        set(handles.text_readyproc, 'String', 'Refining');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
        
        if ~isnan(handles.info.seconds_per_frame)
            set(handles.text_processing_time, 'Visible', 'on')
            set(handles.text_processing_time_label, 'Visible', 'on')
        end
        
        set(handles.text_processing_layer, 'Visible', 'on')
        set(handles.text_processing_layer_label, 'Visible', 'on') 
        
        set(handles.radiobutton_stop, 'Visible', 'on'); 
    case 'xml'
        set(handles.text_readyproc, 'String', 'Reading XML');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
    case 'loading'
        set(handles.text_readyproc, 'String', 'Loading');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
    case 'saving'
        set(handles.text_readyproc, 'String', 'Saving');
        set(handles.text_readyproc, 'ForegroundColor', [1 0 0]);
end

drawnow;
    