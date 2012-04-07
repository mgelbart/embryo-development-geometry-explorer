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


function [AI, BI] = CStrAinBP(A, B, CaseSensitive)
% Cell strings: Find positions of strings of A in B [MEX]
% The M-version is a proof of concept for the faster MEX function.
%
% [AI, BI] = CStrAinBP(A, B, CaseSensitive)
% INPUT:
%   A, B: Cell strings of any size.
%   CaseSensitive: If this string starts with 'i', the upper/lower case of the
%         strings is ignored. Optional, default: 'sensitive'.
% OUTPUT:
%   AI:   Indices of common strings in A as [1 x N] vector.
%         Each occurence of repeated strings in A is considered.
%         AI is sorted from low to high indices.
%   BI:   Indices of common strings in B as [1 x N] vector. If B is not unique,
%         the first occurrence is used.
%   such that A{AI} == B{BI}.
%
% NOTES:
% - CHAR-arrays are treated as strings and the shape is ignored in the MEX.
% - If A or B are multi-dimensional cell arrays, AI and BI are the linear
%   indices (see IND2SUB).
% - The M-version is about 10 times faster than FIND(ISMEMBER) depending on
%   the input. The compiled MEX script is about 20 times faster.
% - In opposite to Matlab's INTERSECT, A(AI) is not necessarily unique if
%   A is not either.
% - In the MEX verion, CHAR arrays are treated as string with linear index:
%   ['ac'; 'bd'] is processed as 'abcd'.
%
% EXAMPLES:
%   [AI, BI] = CStrAinBP({'a', 'b', 'q', 'a'}, {'a', 'c', 'd', 'a', 'b'})
%   replies: AI = [1, 2, 4]  and: BI = [1, 5, 1]
%
%   [AI, BI] = CStrAinBP({'a', 'b', 'A'}, {'a', 'c', 'a', 'B', 'b'}, 'i')
%   replies: AI = [1, 2, 3]  and: BI = [1, 4, 1]
%
% Tested: Matlab 6.5, 7.7, 7.8, Win2K/XP, [UnitTest]
% Author: Jan Simon, Heidelberg, (C) 2006-2009 J@n-Simon.De
%
% See also CStrAinB, CStrAinBPi, ISMEMBER, INTERSECT.

% $JRev: R0g V:040 Sum:6CC11663 Date:13-Sep-2009 02:09:06 $
% $File: Tools\GLSets\CStrAinBP.m $
% History:
% 028: 01-Dec-2006 14:02, Accept inputs of any size.
% 031: 31-Dec-2007 15:08, No Matlab 5 anymore: NUMEL.
% 040: 12-Sep-2009 12:36, 3rd argument for case-sensitivity.
%      This is slows down the M-version, but is fast in the MEX.

% ==============================================================================
% For every string in A look for the first occurrence in B.
nA = numel(A);
nB = numel(B);

if nargin > 2 && strncmpi(CaseSensitive, 'i', 1)  % Ignore case: ---------------
   if nA < nB
      % Collect the index of the first occurrence in B for every A:
      M = zeros(1, nA);
      for iA = 1:nA
         Ind = find(strcmpi(A{iA}, B));
         if length(Ind)
            M(iA) = Ind(1);
         end
      end
      
   else  % nB <= nA, B is smaller, so better loop over B:
      % Mark every A which equal the current B
      M = zeros(1, nA);
      for iB = nB:-1:1
         M(strcmpi(B{iB}, A)) = iB;  % Same as M(find(strcmp()))
      end
   end
   
else  % Case-sensitive comparison: ---------------------------------------------
   if nA <= nB
      % Collect the index of the first occurrence in B for every A:
      M = zeros(1, nA);
      for iA = 1:nA
         Ind = find(strcmp(A{iA}, B));   % FIND(., 1) of Matlab 7 is slower?!
         if length(Ind)
            M(iA) = Ind(1);
         end
      end
      
   else  % nB <= nA, B is smaller, so better loop over B:
      % Mark every A which equal the current B
      M = zeros(1, nA);
      for iB = nB:-1:1
         M(strcmp(B{iB}, A)) = iB;  % Same as M(find(strcmp()))
      end
   end
end

AI = find(M);  % If any occurrence was found, this A exists...
BI = M(AI);    % at this index in B

return;
