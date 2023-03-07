function [W2, J] = wavelets(I)

    % convolution filters for 1st and 2nd wavelet
    k1 = [1/16,1/4,3/8,1/4,1/16];
    k2 = [1/16,0,1/4,0,3/8,0,1/4,0,1/16];

    % do the wavelet filtering ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    W0 = I; %this is the background subtracted image
    F1 = conv2(k1,k1,W0,'same');
    F2 = conv2(k2,k2,F1,'same');
    W2 = W0-F1; %first level wavelet for determining standard deviation of image
    J = F1-F2; %second level wavelet for determining particle locations with imregionalmax

