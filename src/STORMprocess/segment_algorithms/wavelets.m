function [W2, J] = wavelets(I)
% [W2, J] = WAVELETS(I)

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

    % convolution filters for 1st and 2nd wavelet
    k1 = [1/16,1/4,3/8,1/4,1/16];
    k2 = [1/16,0,1/4,0,3/8,0,1/4,0,1/16];

    % do the wavelet filtering ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    W0 = I; %this is the background subtracted image
    F1 = conv2(k1,k1,W0,'same');
    F2 = conv2(k2,k2,F1,'same');
    W2 = W0-F1; %first level wavelet for determining standard deviation of image
    J = F1-F2; %second level wavelet for determining particle locations with imregionalmax

