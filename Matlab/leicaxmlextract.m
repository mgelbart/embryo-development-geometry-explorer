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


%This function extracts relevant imaging parameters from an LAF xml file.
%
% Written by Jeff Drocco, jdrocco_at_princeton.edu
% Dependencies:
% xmliotools suite by Jarek Tuszynski, rev. 06/14/2008

function xmlstruct=leicaxmlextract(tree)

    if(length(tree.Image.ImageDescription.Dimensions.DimensionDescription)>2)
        stacksize=tree.Image.ImageDescription.Dimensions.DimensionDescription(3).ATTRIBUTE.NumberOfElements;
        if(stacksize)
            zstep=tree.Image.ImageDescription.Dimensions.DimensionDescription(3).ATTRIBUTE.Length/(stacksize-1);
        end
    end
    xpixels=tree.Image.ImageDescription.Dimensions.DimensionDescription(1).ATTRIBUTE.NumberOfElements;
    ypixels=tree.Image.ImageDescription.Dimensions.DimensionDescription(2).ATTRIBUTE.NumberOfElements;
    xdimreal=tree.Image.ImageDescription.Dimensions.DimensionDescription(1).ATTRIBUTE.Length;
    ydimreal=tree.Image.ImageDescription.Dimensions.DimensionDescription(2).ATTRIBUTE.Length;
    xorigin=tree.Image.ImageDescription.Dimensions.DimensionDescription(1).ATTRIBUTE.Origin;
    yorigin=tree.Image.ImageDescription.Dimensions.DimensionDescription(2).ATTRIBUTE.Origin;
    % Here we extract the number of pixels and total length in x and y, similar
    % idea but by stepzsize for z
    intervalsinseries=length(tree.Image.TimeStampList.TimeStamp);
    timeinmin=zeros(1,intervalsinseries);
    for j=1:intervalsinseries
        timeinmin(j)=(tree.Image.TimeStampList.TimeStamp(j).ATTRIBUTE.HighInteger-29900000)*429.4967/60+tree.Image.TimeStampList.TimeStamp(j).ATTRIBUTE.LowInteger/(60*10000000);
    end
    % Here we calculate the time stamp in minutes from the metadata.  Absolute
    % zero is some time in late 2007.
    numrawchans=length(tree.Image.ImageDescription.Channels.ChannelDescription);
    % We also find the number of channels to import.
    
    if(exist('stacksize')&&exist('zstep'))
        xmlstruct=struct('stacksize',stacksize,'xpixels',xpixels,'ypixels',ypixels,'xdimreal',xdimreal,'ydimreal',ydimreal,'zstep',zstep,'numrawchans',numrawchans,'timeinmin',timeinmin,'xorigin',xorigin,'yorigin',yorigin);
    else
        xmlstruct=struct('xpixels',xpixels,'ypixels',ypixels,'xdimreal',xdimreal,'ydimreal',ydimreal,'numrawchans',numrawchans,'timeinmin',timeinmin,'xorigin',xorigin,'yorigin',yorigin);
    end
