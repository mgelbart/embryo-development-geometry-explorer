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


% Get the membranes from a raw image of cells. First filter (lp, hp), then
% threshold (th), then do all the skeletonization and cleaning up. 

function cellsi = get_membs_v3(cells, lp, hp, th)


% preprocessing
cells = cells - mean(mean(cells));     %subtract mean  

%truncate values at +- trunc_th standard deviations
sigma = std(cells(:));
trunc_th = 2;

cells(cells>=trunc_th*sigma)=trunc_th*sigma;  %find wherever cells is greater than this threshold and set it to this threshold
cells(cells<=-trunc_th*sigma)=-trunc_th*sigma;  %same for below the bottom threshold
%filtering


% relatively slow?
[cellsf,filt] = get_filtered(cells,lp,hp);  %cellsf is the filtered cells array



% thresholding and binary and start skeletonizing
bw_thresh = th * std(cellsf(:));

cellsX = im2bw(cellsf - bw_thresh, 0); 

[Ys Xs] = size(cellsX);  % in case get_filtered returns something
                         % different in size by 1 pixel
% throw away the outer edges
mask=ones(Ys,Xs);
ddx=2;ddy=2; 
mask(1:ddy,:) = 0; mask(Ys-ddy+1:Ys,:) = 0; mask(:,1:ddx) = 0; mask(:,Xs-ddx+1:Xs) = 0;

cellsX(mask==0)=1;
cellsi = cellsX == 1;

% skeletonize (relatively slow?)
cellsi = bwmorph(cellsi,'shrink',Inf);    %thins to 1 px
cellsi = bwmorph(cellsi,'clean');   %gets rid of single dots

cellsi(mask==0)=0;
% label cells by integers; every cell gets addressed
cellsi = logical(cellsi);