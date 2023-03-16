function [xdiffs, ydiffs] = showtform(reverse_transform)
% [XDIFFS, YDIFFS] = SHOWTFORM(REVERSE_TRANSFORM)

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
w = 256;
h = 512;

[xs, ys] = meshgrid(1:h, 1:w);

[xt, yt] = tforminv(reverse_transform, xs,ys);

xdiffs = xs - xt;
ydiffs = ys - yt;

mx = median(xdiffs(:));
my = median(ydiffs(:));

xdiffs(abs(xdiffs - mx) > 10) = NaN;
ydiffs(abs(ydiffs - my) > 10) = NaN;



if nargout == 0
    figHandle = figure;
    set(figHandle, 'Units', 'Normalized', 'Position',  [.2 .2 .6 .6]);
    subplot(1,3,1);
    imagesc(ydiffs'-my);
    ca = caxis;
    cm = colormap;
    cdepth = size(cm,1) - 1;
    cm = [1 0 0; cm];
    colormap(cm);
    dmap = diff(ca)/cdepth;
    caxis(ca - [dmap, 0]);
    hcb = colorbar('SouthOutside');
    xlim(hcb, ca + [dmap 0]);
    axis equal off;
    title('X transform');

    subplot(1,3,2);
    imagesc(xdiffs' - mx);
    ca = caxis;
    cm = colormap;
    cdepth = size(cm,1) - 1;
    cm = [1 0 0; cm];
    colormap(cm);
    dmap = diff(ca)/cdepth;
    caxis(ca - [dmap, 0]);
    hcb = colorbar('SouthOutside');
    xlim(hcb, ca + [dmap 0]);
    axis equal off;
    title('Y transform');
    
    subplot(1,3,3);
    indsx = 10:32:(h-10); indsy = 10:32:(w-10);
    quiver(ys(indsy, indsx), xs(indsy, indsx), ...
        ydiffs(indsy, indsx) - my, ...
        xdiffs(indsy, indsx) - mx);
    xlim([-1 w+1]); ylim([-1 h + 1]);
    set(gca, 'YDir', 'Reverse');
    axis equal off;
end
