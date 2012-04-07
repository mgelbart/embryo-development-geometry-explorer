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


function [smo_out,hf_out,roc_out]=smooth_rochange_2(data, sigma, dt)
% smooths each column of the incoming data, 
% using a Gaussian 
% smoothing with window size 5 and sigma input.

% returns...
% the smoothed data (smo_out)
% the high frequency component, original - smoothed, (hf_out)
% the rate of changes based on the smoother data (roc_out)

if isempty(data)
    smo_out = [];
    hf_out = [];
    roc_out = [];
    return;
end

if sigma > 0
    WINDOW_SIZE = 10;%1 + floor(1*sigma);

    % convert sigma from seconds to index units
    stdev = sigma / dt; 
    rowdata = data.';

    % pad the data
    left_pad = repmat(rowdata(:, 1), 1, WINDOW_SIZE);
    right_pad = repmat(rowdata(:, end), 1, WINDOW_SIZE);
    background = [left_pad rowdata right_pad];

    % smooth using the built-in "smoothts" function with the Gaussian option
    smoothed = smoothts(background, 'g', WINDOW_SIZE, stdev);

    % unpad (extract it from the background elements)
    smo_out = smoothed(:, 1+WINDOW_SIZE:end-WINDOW_SIZE);
    smo_out = smo_out.'; % back to original orientation (columns)
else
    smo_out = data;
end

% calculate high frequency
hf_out = smo_out - data;

% find the rate of change
% (diff acts along 1st dimention by default)
roc_out = diff(smo_out) / dt;
% add NaN to the end so it is the same length
roc_out(end+1, :) = NaN;

