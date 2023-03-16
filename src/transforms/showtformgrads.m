function [xgradx, xgrady, ygradx, ygrady] = showtformgrads(reverse_transform)
% [XGRADX, XGRADY, YGRADX, YGRADY] = SHOWTFORMGRADS(REVERSE_TRANSFORM)

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

[xs, ys] = meshgrid(1:512, 1:256);

[xt, yt] = tforminv(reverse_transform, xs,ys);

xdiffs = xs - xt;
ydiffs = ys - yt;

mx = median(xdiffs(:));
my = median(ydiffs(:));

xdiffs(abs(xdiffs - mx) > 10) = NaN;
ydiffs(abs(ydiffs - my) > 10) = NaN;

[xgradx, xgrady] = gradient(xdiffs);
[ygradx, ygrady] = gradient(ydiffs);

if nargout == 0
    figure;
    subplot(2,2,1);
    imagesc(xgradx'); colorbar;
    title('d(\Delta x)/dx');

    subplot(2,2,2);
    imagesc(xgrady'); colorbar;
    title('d(\Delta x)/dy');

    subplot(2,2,3);
    imagesc(ygradx'); colorbar;
    title('d(\Delta y)/dx');

    subplot(2,2,4);
    imagesc(ygrady'); colorbar;
    title('d(\Delta y)/dy');
end
