function [xgradx, xgrady, ygradx, ygrady] = showtformgrads(reverse_transform)

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
