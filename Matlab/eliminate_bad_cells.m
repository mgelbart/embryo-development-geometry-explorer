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


% Clean up an image "input" and remove unwanted cells. First, perform
% erosions if necessary to remove junk on the outside of the image. Then, 
% remove cells with area smaller than min_cell_sz, which is given in
% pixel^2

function [dirty clean] = eliminate_bad_cells(...
    input, min_cell_sz, num_erosions)

% remove junk on the outside
if num_erosions > 0
    for erode = 1:num_erosions
        input = fix_outer_cells_preserve_vertices(input);
    end
    % the below lines should not be here when the rest of the function
    % is uncommented, because it gets done at the bottom anyway!
    dirty = bwmorph(input, 'skel', Inf);
    clean = bwmorph(dirty, 'shrink', Inf);
    clean = bwmorph(clean,  'clean',  Inf);
else
    dirty = input;
    clean = input;
end


% this part is removed for speed in favor of doing it in the CellGraph
% constructor. however, it is unclear that the other method is always
% faster. if you have TONS of small cells, then it's better to get rid of
% them with this method that probably doesnt scale that badly, as opposed
% to going through the CellGraph constructor with so many cells before
% finally removing the small ones at the last step.

% regions = bwlabel(logical(1-input), 4);
% 
% % now it will not ignore any of the regions,
% % since it sometimes confuses the borders as the background
% regions = regions + 1;
% 
% tic
% S = regionprops(regions, 'Area', 'Solidity');
% toc
% tic
% cellAreas1 = [S.Area];
% areas = [cellAreas1; 1:length(cellAreas1)]';
% 
% 
% sol1 = [S.Solidity];
% solidity = [sol1; 1:length(sol1)]';
% toc
% tic
% [~, bordindex] = min(solidity(:,1));
% toc
% 
% badcells = areas(areas(:,1) < min_cell_sz, 2);
% badcells = badcells(:);
% 
% tic
% % make those into BORDERS and then skeletonize
% for i = 1:length(badcells)
%     regions(regions == badcells(i)) = bordindex;
% end
% toc
% 
% tic
% borders = regions == bordindex;
% 
% dirty = bwmorph(borders, 'skel', Inf);
% clean = bwmorph(dirty, 'shrink', Inf);
% clean = bwmorph(clean,  'clean',  Inf);
