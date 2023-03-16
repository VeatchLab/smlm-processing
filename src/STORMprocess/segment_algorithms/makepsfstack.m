function [psfstack,Ninframe,others] = makepsfstack(Iall, coords, dL, varargin)
% [PSFSTACK,NINFRAME,OTHERS] = MAKEPSFSTACK(IALL, COORDS, DL, VARARGIN)

% Copyright (C) 2023 Thomas Shaw and Sarah Veatch
% This file is part of SMLM PROCESSING 
% SMLM PROCESSING is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% SMLM PROCESSING is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with SMLM PROCESSING.  If not, see <https://www.gnu.org/licenses/>
    nframes = size(Iall,3);    
    dL = round(dL); % dL is used for indexing, so should be integer
    
    % compute frame offsets.
    % indices for frame i are:
    %  (1:Ninframe(i)) + frameOff(i)
    next = 0;
    Ninframe = zeros(1,nframes);
    frameOff = zeros(1,nframes);
    for i = 1:nframes
        Ninframe(i) = size(coords{i},1);
        frameOff(i) = next;
        next = next + Ninframe(i);
    end

    n = next; % total number of psfs in stack
    nextras = numel(varargin);

    roiwidth = 2*dL + 1;
    psfstack = zeros(roiwidth,roiwidth,n);
    others = cell(1,nextras);
    for k = 1:nextras
        others{k} = zeros(roiwidth,roiwidth,n);
    end

    for i = 1:nframes
        c = coords{i};
        I = Iall(:,:,i);
        if numel(c) > 0 %sum(c(:))>0 %deal with nothing making it through segmentation this frame.
            for j = 1:size(c,1)
                next = j + frameOff(i);
                % left, right, top, bottom of roi (region of interest)
                l = c(j,1) - dL; r = c(j,1) + dL;
                t = c(j,2) - dL; b = c(j,2) + dL;
                roi = I(t:b,l:r);
                for k = 1:nextras
                    others{k}(:,:,next) = varargin{k}(t:b,l:r);
                end
                psfstack(:,:,next) = roi;
            end
        end
    end
end
