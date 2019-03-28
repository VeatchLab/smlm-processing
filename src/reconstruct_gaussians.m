function [ I ] = reconstruct_gaussians(data, iref, psfsigma)
%SIMSTORM Summary of this function goes here
%   Detailed explanation goes here

allx = [data.x];
ally = [data.y];

Nemit = numel(allx);

% figure out stuff from iref
pwidth = iref.PixelExtentInWorldX;
pheight = iref.PixelExtentInWorldY;

% get image limits, in px units, shifting to start on integer
left = iref.XWorldLimits(1)/pwidth;
dx = left - floor(left);
left = left - dx;
right = iref.XWorldLimits(2)/pwidth - dx;

top = iref.YWorldLimits(1)/pheight;
dy = top - floor(top);
top = top - dy;
bottom = iref.YWorldLimits(2)/pheight - dy;

% non-dimensionalize
coords = [allx'/pwidth - dy, ally'/pheight - dy];
psfsigma = psfsigma/(mean(pwidth, pheight));
if pwidth ~= pheight
    warning('pixel width and height are different');
end

bound = .01; % intensity cutoff -- make psfs out far enough that no pixel
% of more than this intensity is unaccounted for
radius = ceil(sqrt(-2*psfsigma^2*log(bound*pi*psfsigma^2)));
width_small = 2*radius + 1;

width = iref.ImageSize(2);
height = iref.ImageSize(1);

I = zeros(width, height);

% Choose a random sample of emitters

Ism = finitegausspsf(width_small,psfsigma,1,0, coords - round(coords) + radius + .5);

for j = 1:Nemit
    x = coords(j,1); y = coords(j,2);
    % Indices in large image of top left corner of small image
    pxl = round(x) - radius - left; pyt = round(y) - radius - top;
    
    % Find index ranges in the small and large images of the parts that
    % overlap
    ix = max(pxl,1):min(pxl + width_small -1, width);
    iy = max(pyt,1):min(pyt + width_small -1, height);
    
    jx = ix - pxl + 1;
    jy = iy - pyt + 1;
    
    I(ix, iy) = I(ix,iy) + Ism(jx, jy, j);
end

I = I';
