function [ out ] = maskedRegionalMax( I, BW )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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
[xs, ys] = find(BW); % Condidates

I = I .*BW;
out = I;

[maxx, maxy] = size(I);

for i = 1:length(xs),
    x= xs(i); y = ys(i);
    val = I(x,y);
    if x > 1,
        lx = -1;
    else
        lx = 0;
    end
    if y > 1,
        ly = -1;
    else
        ly = 0;
    end
    if x<maxx,
        ux = 1;
    else
        ux = 0;
    end
    if y<maxy,
        uy = 1;
    else
        uy = 0;
    end
    
    for j = lx:ux,
        for k = ly:uy,
            if j || k,
                test = I(x+j, y+k);
                if test > val,
                    out(x,y) = 0;
                    break
                end
            end
        end
        if out(x,y) == 0,
            break
        end
    end

end

