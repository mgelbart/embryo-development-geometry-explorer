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


function [smo_out,hf_out,roc_out]=smooth_rochange(data,sigma,dt)
% input
% data= 2D input array (n timeseries), smoothed along FIRST dimension
% sigma= width of Gaussian smoothing kernel
% dt= time resolution, time per pixel
% output
% smo= smoothed vertion of q
% hf= high freq part of q (q-smo)
% roc= rate of change (calc. based on smo)

smo_out = zeros(size(data));
hf_out = zeros(size(data));
roc_out = zeros(size(data));

for I = 1:size(data, 2)
    q = data(:, I).';
    q_old = q;  
    firstNaN = find(isnan(q), 1);
    if (isempty(firstNaN))
        firstNaN = length(q) + 1;
    end
    % after the first NaN entry, all data is ignored
    % this is not so ideal
    q(firstNaN:end) = [];
    q_old(firstNaN:end) = NaN;
    %q_old is used to put the smoothed stuff
    % back in the right sized array and then pacakge it
    if firstNaN == 1
        continue;
    end
  %%  
    % create  backgraound array
    framesize=fix(4*sigma);
    aa = size(q)+[0 2*framesize];
    [xx,yy] = meshgrid(1:aa(2),1:aa(1)); 
    xx=xx-aa(2)/2;

    % filter kernel
    filt=exp(-xx.^2/2.0/sigma^2)/sqrt(2*pi)/sigma;
    filt=circshift(filt,[0,fix(aa(2)/2)+1]);
    filtk=fft(filt,[],2);

    if (sigma==0)
       filtk=ones(aa(1),aa(2)); 
    end

    %norm to avoid edge effects
    norm=zeros(aa(1),aa(2));
    norm(:,framesize+1:end-framesize)=1;
    norm=real(ifft(filtk.*fft(norm,[],2),[],2));
    norm=norm(:,framesize+1:end-framesize);

    %smoothing
    bg=zeros(aa(1),aa(2));
    bg(:,framesize+1:end-framesize)=q;
    fbg = fft(bg,[],2);
    bgsm=real(ifft(fbg.*filtk,[],2));
    smo=bgsm(:,framesize+1:end-framesize)./norm;
    hf = q-smo;
    if (sigma==0)
       hf=hf*0; 
    end
%%

    % rate-of-change
    ll=circshift(smo,[0 -1]);
    rr=circshift(smo,[0 1]);
    roc=(ll-rr)/dt/2;
    roc(:,1)=NaN;
    roc(:,end)=NaN;
    
    z = q_old;
    z(1:firstNaN-1) = smo;
    smo_out(:, I) = z.';
    z = q_old;
    z(1:firstNaN-1) = hf;
    hf_out(:, I)  = z.';
    z = q_old;
    z(1:firstNaN-1) = roc;
    roc_out(:, I) = z.';
    
end

