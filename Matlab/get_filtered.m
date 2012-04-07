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


% Applies bandpass filter (between llp and hhp, measured in pixels) to the
% image "cells". This function written mostly by Matthias Kaschube. Returns
% the filtered image and the filter itself.

function [cellsf,filt] = get_filtered(cells,llp,hhp)

%cells = array of cells
%ext = size of background array
%llp = low pass cutoff (pixels)
%hhp = high pass cutoff (pixels)
%beta = sharpness of filter

% Bandpass-filtering of image. In Fourier Domain. Returns filtered image
% and filter kernel. 

a = size(cells);


beta = 8;   % sharpness of filter
ext = 2^(ceil(log2(max(a)))); % smallest power of 2 bigger than Xs and Ys


bg=zeros(ext);     % put on square array of size 2^N

bg(floor((ext-a(1))/2) + 1:floor((ext-a(1))/2)+a(1), floor((ext-a(2))/2)+1:floor((ext-a(2))/2)+a(2))=cells;

[xx,yy] = meshgrid(1:ext,1:ext);   % coordinate system
xx=xx-ext/2;
yy=yy-ext/2;

% Fermi bandpass filter
lp=ext/llp;
hp=ext/hhp;
filt=1./(1+exp((sqrt(xx.^2+yy.^2)-lp)./(beta)));
filt=filt-1./(1+exp((sqrt(xx.^2+yy.^2)-hp)./(beta)));

% multiplying by filter in Fourier domain
fourier_temp = fft2(bg);

fourier_temp = fourier_temp.*fftshift(filt);

cellsf=real(ifft2(fourier_temp));  

cellsf=cellsf(floor((ext-a(1))/2)+1:floor((ext-a(1))/2)+a(1), ...
    floor((ext-a(2))/2)+1:floor((ext-a(2))/2)+a(2));
cellsf=cellsf-mean(mean(cellsf));
filt=filt(floor((ext-a(1))/2)+1:floor((ext-a(1))/2)+a(1),floor((ext-a(2))/2)+1:floor((ext-a(2))/2)+a(2));

% % pad with zeros if necessary to get an even number
% if mod(size(cells, 1), 2)==1
%     cellsf = [cellsf; zeros(1, size(cells, 2))];
% end
% if mod(size(cells, 2), 2)==1
%     cellsf = [cellsf zeros(size(cells, 1), 1)];
% end