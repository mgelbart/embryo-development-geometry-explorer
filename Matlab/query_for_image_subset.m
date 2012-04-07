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


function q = query_for_image_subset()

q = [];
prompt = {'Enter Z-range (e.g., 5-10):', ...
            'Enter T-range (e.g., 0):'};
dlg_title = 'Input which images to process';
num_lines = 2;
defaultanswer = {'',''};
%     options.Resize='on';
options.WindowStyle='normal';
%         options.Interpreter='tex';
answer = inputdlg(prompt, dlg_title, num_lines, defaultanswer, options);

if isempty(answer) || isempty(answer{1})
    return;
end;

z_do   = answer{1}(1,:);        
if size(answer{1}, 1) == 2
    z_skip = answer{1}(2,:);
else
    z_skip = [];
end

t_do   = answer{2}(1,:);
if size(answer{2}, 1) == 2
    t_skip = answer{2}(2,:);
else
    t_skip = [];
end


q.z_do_range   = parse_range(z_do);
q.z_skip_range = parse_range(z_skip);
q.t_do_range   = parse_range(t_do);
q.t_skip_range = parse_range(t_skip);