function [C, G1, G2] = xcornew(data1, data2, maskx, masky, pixsize, rmax )

% make an imref2d
wpix = ceil((max(maskx) - min(maskx))/pixsize); % Width in pixels
lpix = ceil((max(masky) - min(masky))/pixsize); % Length in pixels
w = wpix*pixsize; % width in real units, rounding up to nearest pixel edge
l = lpix*pixsize; % length in real units, rounding up to nearest pixel edge
xextent = min(maskx) + [0, w];
yextent = min(masky) + [0, l];

iref = imref2d([lpix,wpix], xextent, yextent);

% construct mask
[row, col] = iref.worldToSubscript(maskx, masky);
BW = roipoly(zeros(iref.ImageSize), col, row);

% generate storm images
[I1_raw] = reconstruct(data1, iref);
[I2_raw] = reconstruct(data2, iref);

I1_masked = I1_raw .* BW;
I2_masked = I2_raw .* BW;

psize = iref.PixelExtentInWorldX;
if abs(iref.PixelExtentInWorldY - psize) > 1e-8
    error('x and y pixel extents are not equal');
end

Amask = sum(sum(BW)); %*psize^2;

% densities are in 1/units^2, using the units of x,y coordinates
loc_density1 = sum(sum(I1_masked))/Amask;
loc_density2 = sum(sum(I2_masked))/Amask;

fftsize1 = size(BW,1) + round(rmax/pixsize) - 1;
fftsize2 = size(BW,2) + round(rmax/pixsize) - 1;

% normalization for edge effects
N = fftshift(ifft2(abs(fft2(BW, fftsize1, fftsize2)).^2));

% The cross correlation
densityfactor = 1/(loc_density1*loc_density2);

C = densityfactor * abs(fftshift(ifft2( fft2(I1_masked, fftsize1, fftsize2).* ...
                        conj(fft2(I2_masked, fftsize1, fftsize2))))) ./ N;

G1 = 1/(loc_density1) * fftshift(ifft2( ...
            abs(fft2(I1_masked, fftsize1, fftsize2)).^2))./N;
G2 = 1/(loc_density2) * fftshift(ifft2( ...
            abs(fft2(I2_masked, fftsize1, fftsize2)).^2))./N;

