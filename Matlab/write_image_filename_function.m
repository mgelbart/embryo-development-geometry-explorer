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


function handle = write_image_filename_function(SRC, name, z_posn, z_digits, t_posn, t_digits, fixed, data_set_name)

fid = fopen(fullfile(SRC, 'image_filename.m'), 'w');

fprintf(fid, '%s\n', 'function data = image_filename(time_i, layer_i, src)');
fprintf(fid, '%s\n', '% ** This is an automatically generated function');
fprintf(fid, '%s%s%s\n', '% ** created at ', date_and_time, ' by write_image_filename_function.m');
fprintf(fid, '%s\n%s\n\n', '% ** Inputs the time, layer, and source directory of a data set.', ...
    '% ** Outputs the filename of that image.');
fprintf(fid, '%s%s\n\n', '% ** For data set: ', data_set_name);
fprintf(fid, '%s%s%s\n\n', 'filename = ''', name, ''';');
fprintf(fid, '%s%u%s\n', 'z_name = sprintf(strcat(''%.'', num2str(', z_digits, ...
    '), ''u''), layer_i);');
fprintf(fid, '%s%u%s%u%s%u%s\n\n', 'filename(', z_posn, ':', z_posn, '+', z_digits, ...
    '-1) = z_name;');
if ~fixed
    fprintf(fid, '%s%u%s\n', 't_name = sprintf(strcat(''%.'', num2str(', t_digits, ...
        '), ''u''), time_i);');
    fprintf(fid, '%s%u%s%u%s%u%s\n\n', 'filename(', t_posn, ':', t_posn, '+', t_digits, ...
        '- 1) = t_name;');
end
fprintf(fid, '%s\n', 'data = fullfile(src, filename);');
fclose(fid);

current_dir = pwd;
cd(SRC);
handle = @image_filename;
cd(current_dir);

% ** this function should make a function that looks like this: **

% function data = image_filename(time_i, layer_i, src)
% filename = 'Series001_t000_z0_ch00.tif';
% 
% z_name = sprintf(strcat('%.', num2str(3), 'u'), layer_i);
% filename(8 : 8 + 3 - 1) = z_name;
% 
% t_name = sprintf(strcat('%.', num2str(2), 'u'), time_i);
% filename(4 : 4 + 2 - 1) = t_name;
% 
% data = fullfile(src, filename);


