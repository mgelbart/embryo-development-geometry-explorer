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


% Erodes the image by deleting pixels close to the boundary
% from all 4 sides. Does not delete a pixel if it is vertex
% The code here is horrible. it could be much
% faster and probably otherwise better. But that's ok, people don't use
% this function much anyway ;)


function bords = fix_outer_cells_preserve_vertices(x)


Ys = size(x, 1);
Xs = size(x, 2);

% the old definition of vertices, different from bwmorph('branchpoints')
f = @(x) (x(2,2) && (sum(x(:)) >= 4));
lut = makelut(f, 3);
vertplot = applylut(x, lut);



bords = x;

for i = 1:Ys
    for j = 1:Xs
        if x(i, j)
            if ~vertplot(i, j)
                bords(i, j) = 0;
            end
            break;
        end
    end
end

for i = 1:Ys
    for j = Xs:-1:1
        if x(i, j)
            if ~vertplot(i, j)
                bords(i, j) = 0;
            end
            break;
        end
    end
end




for i = 1:Xs
    for j = 1:Ys
        if x(j, i)
            if ~vertplot(j, i)
                bords(j, i) = 0;
            end
            break;
        end
    end
end

for i = 1:Xs
    for j = Ys:-1:1
        if x(j, i) 
            if ~vertplot(j, i)
                bords(j, i) = 0;
            end
            break;
        end
    end
end