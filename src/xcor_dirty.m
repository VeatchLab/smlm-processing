function [C] = xcor_dirty(data1, data2, pixsize, rmax)
% [C] = XCOR_DIRTY(DATA1, DATA2, PIXSIZE, RMAX)

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

% make an imref2d
x1 = [data1.x]; y1 = [data1.y];
x2 = [data2.x]; y2 = [data2.y];

if isempty(x1) || isempty(x2)
    C = [];
    return
end

maxx = max(max(x1), max(x2));
minx = min(min(x1), min(x2));
maxy = max(max(y1), max(y2));
miny = min(min(y1), min(y2));
wpix = ceil( (maxx - minx)/pixsize ); % Width in pixels
lpix = ceil( (maxy - miny)/pixsize ); % Length in pixels
w = wpix*pixsize; % width in real units, rounding up to nearest pixel edge
l = lpix*pixsize; % length in real units, rounding up to nearest pixel edge
xextent = minx + [0, w];
yextent = miny + [0, l];

iref = imref2d([lpix,wpix], xextent, yextent);

% generate storm images
[I1_raw] = reconstruct(data1, iref);
[I2_raw] = reconstruct(data2, iref);

psize = iref.PixelExtentInWorldX;
if abs(iref.PixelExtentInWorldY - psize) > 1e-8
    error('x and y pixel extents are not equal');
end

% densities are in 1/units^2, using the units of x,y coordinates
loc_density1 = sum(sum(I1_raw))/(w*l);
loc_density2 = sum(sum(I2_raw))/(w*l);

fftsize1 = size(I1_raw,1) + round(rmax/pixsize) - 1;
fftsize2 = size(I1_raw,2) + round(rmax/pixsize) - 1;

% The cross correlation
densityfactor = 1/(loc_density1*loc_density2);

C = densityfactor * abs(fftshift(ifft2( fft2(I1_raw, fftsize1, fftsize2).* ...
                        conj(fft2(I2_raw, fftsize1, fftsize2)))));
