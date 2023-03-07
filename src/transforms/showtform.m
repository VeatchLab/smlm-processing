function [xdiffs, ydiffs] = showtform(reverse_transform)
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
