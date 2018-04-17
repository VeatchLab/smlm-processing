function [Imerge, ir] = imerge_from_imagestruct(istruct)

ir = default_iref(istruct.data{1}, istruct.psize);

d1 = istruct.data{1};
d2 = istruct.data{2};

I1 = reconstruct(d1, ir);
I2 = reconstruct(d2, ir);

% sigmas need to be in units of reconstruction pixels
sigma1 = istruct.sigmablur{1}/istruct.psize; 
sigma2 = istruct.sigmablur{2}/istruct.psize;

PSF1 = 2*pi*sigma1^2*fspecial('gaussian', ceil(4*sigma1), sigma1);
PSF2 = 2*pi*sigma2^2*fspecial('gaussian', ceil(4*sigma2), sigma2);

Iblur1 = imfilter(I1, PSF1, 'replicate');
Iblur2 = imfilter(I2, PSF2, 'replicate');

clim1 = istruct.clim{1};
clim2 = istruct.clim{2};

If1 = (Iblur1 - clim1(1))/(diff(clim1));
If2 = (Iblur2 - clim2(1))/(diff(clim2));

Imerge = cat(3, If1, If2, If1);
