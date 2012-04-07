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


function import_copymove_files(handles, image_file, dest, rm_files, sample_image)
% copy the imported files from the import directory to the EDGE directory
% image_file is the image file *function* for this data but with the source
    % already specified so that only a time and layer are needed
% dest is the destination directory
% rm_files is boolean and says whether or not to remove the originals
% sample_image is just a sample image to check if it needs rgb2gray


for time_i = handles.info.start_time:handles.info.end_time
    set(handles.text_processing_time,  'String', num2str(time_i));
    for layer_i = handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer
        if get(handles.radiobutton_stop, 'Value')
            set(handles.radiobutton_stop, 'Value', 0);
            readyproc(handles, 'ready');
            msgbox('Import interrupted by user - please try again', 'Import failed');    
            guidata(hObject, handles);
            return;
        end

        set(handles.text_processing_layer, 'String', num2str(layer_i));
        drawnow

        copymove_src = image_file(time_i, layer_i);
        if rm_files
            movefile(copymove_src, dest);
        else
            copyfile(copymove_src, dest);
        end
    end
end

% make sure all the images are grayscale

if ndims(sample_image) == 3
    readyproc(handles, 'finalizing');
    for time_i = handles.info.start_time:handles.info.end_time
        set(handles.text_processing_time,  'String', num2str(time_i));
        for layer_i = handles.info.bottom_layer:my_sign(handles.info.top_layer-handles.info.bottom_layer):handles.info.top_layer
            set(handles.text_processing_layer, 'String', num2str(layer_i));
            drawnow

            filename = handles.info.image_file(time_i, layer_i, dest);
            out = imread(filename);
            in = rgb2gray(out);
            imwrite(in, filename, handles.file_ext);
         end
    end
end