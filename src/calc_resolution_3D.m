function [res, info] = calc_resolution_3D(data, options);%bin, n, how, maxr)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if nargin<2
    options = resolution_default('nm');
end
rmax = options.maxr;
n = options.niter;
bin = options.binsize;
range = options.range;

data = data';
x = [data(:).x];
y = [data(:).y];
z = [data(:).z];

if isempty(range)
    range = [.05 .95 .05 .95 .05 .95];
end

if sum(range)<6
    minx = quantile(x, range(1));
    maxx = quantile(x, range(2));
    miny = quantile(y, range(3));
    maxy = quantile(y, range(4));
    minz = quantile(z, range(5));
    maxz = quantile(z, range(6));
else
    minx = range(1);
    maxx = range(2);
    miny = range(3);
    maxy = range(4);
    minz = range(5);
    maxz = range(6);
end

zedges = minz:bin:maxz;
if numel(zedges)/2~=round(numel(zedges)/2)
    zedges = minz:bin:maxz+bin;
end

xedges = minx:bin:maxx;
if numel(xedges)/2~=round(numel(xedges)/2)
    xedges = minx:bin:maxx+bin;
end

yedges = miny:bin:maxy;
if numel(yedges)/2~=round(numel(yedges)/2)
    yedges = miny:bin:maxy+bin;
end


pts = [x' y' z'];
Iall = histcn(pts, xedges, yedges, zedges);
XCall = fftshift(ifftn(abs(fftn(Iall)).^2))/sum(Iall(:))^2;

XCsub = zeros(size(XCall));
parfor i=1:n
    range = i:n:numel(data);
    pts_sub = [[data(range).x]' [data(range).y]' [data(range).z]'];

    Isub = histcn(pts_sub, xedges, yedges, zedges);

    XCsub = XCsub+fftshift(ifftn(abs(fftn(Isub)).^2))/sum(Isub(:))^2/n;
end

rmaxpx= min([ceil(rmax/bin), round(size(Iall,3)/2)-1]);
npx = 2*rmaxpx + 1;
pxrange = (-rmaxpx):rmaxpx;
smallinds1 = round(size(Iall,1)/2) + pxrange;
smallinds2 = round(size(Iall,2)/2) + pxrange;
smallinds3 = round(size(Iall,3)/2) + pxrange;
smallrs = ((1:npx)-rmaxpx-1);%*bin;
[Y, X, Z] = meshgrid(smallrs, smallrs, smallrs);

resmat = XCall-XCsub;

resmatsm = resmat(smallinds1, smallinds2,smallinds3);
resmatsm = resmatsm/max(resmatsm(:));
icenter = sub2ind(size(resmatsm), rmaxpx+1, rmaxpx+1,rmaxpx+1);
resmatsm(icenter) = NaN;

 P0 = [1,1,1];
 
inds = isfinite(resmatsm(:));
fitgaus3D = @(P) (P(3)*exp(-(X(inds)/P(1)).^2/4 - (Y(inds)/P(1)).^2/4 - (Z(inds)/P(2)).^2/4)-resmatsm(inds));
[P,resnorm,residual,exitflag,output,lambda,jacobian] = lsqnonlin(fitgaus3D, P0, [0 0 0], [100 100 100]);
ci = nlparci(P,residual,'jacobian',jacobian, 'alpha', .32);
dP = (ci(:, 2)-ci(:, 1))/2;


res = P(1:2)*bin;
info.res_error = dP(1:2)'*bin;
info.rmaxpx = rmaxpx;
info.rmax = rmaxpx*bin;
info.sizeXC = size(XCall);
% 
% % %%
% % fitgauss2Dsym = fittype(...
% %     'A*exp(-(x/2/s).^2 - (y/2/s).^2)', ...
% %         'coefficients', {'A', 's'},...
% %         'indep', {'x', 'y'}, ...
% %         'dep', 'I');
% %     
% % fitgauss2D = fittype(...
% %     'A*exp(-(x/2/s1).^2 - (y/2/s2).^2)', ...
% %         'coefficients', {'A', 's1', 's2'},...
% %         'indep', {'x', 'y'}, ...
% %         'dep', 'I');
% % 
% %     
% % XX = X(:, :, rmaxpx+1);
% % YY = Y(:, :, rmaxpx+1);
% % resmatsmxy = resmatsm(:, :, rmaxpx+1);
% % 
% % inds = isfinite(resmatsmxy);
% % 
% % Fxy = fit([XX(inds), YY(inds)], resmatsmxy(inds), fitgauss2Dsym, 'startpoint', [1 1]);
% % plot(Fxy, [XX(:), YY(:)], resmatsmxy(:))
% % %%
% % XX = squeeze(X(:, rmaxpx+1, :));
% % ZZ = squeeze(Z(:, rmaxpx+1, :));
% % resmatsmxz = squeeze(resmatsm(:, rmaxpx+1, :));
% % inds = isfinite(resmatsmxz);
% % Fxz = fit([XX(inds), ZZ(inds)], resmatsmxz(inds), fitgauss2D, 'startpoint', [1 Fxy.s Fxy.s]);
% % plot(Fxz,[XX(:), ZZ(:)], resmatsmxz(:))
% % 
% % %%
% % YY = squeeze(Y(rmaxpx+1,:, :));
% % ZZ = squeeze(Z(rmaxpx+1,:, :));
% % resmatsmyz = squeeze(resmatsm(rmaxpx+1,:, :));
% % inds = isfinite(resmatsmyz);
% % Fyz = fit([YY(inds), ZZ(inds)], resmatsmyz(inds), fitgauss2D, 'startpoint', [1 Fxy.s Fxy.s]);
% % plot(Fyz,[YY(:), ZZ(:)], resmatsmyz(:))
% %%
% % %imshow(squeeze(testsm(:, rmax, :)), []);
% % 
%  P0 = [1,1,1];
% % 
% inds = isfinite(resmatsm(:));
% fitgaus3D = @(P) (P(3)*exp(-(X(inds)/P(1)).^2/4 - (Y(inds)/P(1)).^2/4 - (Z(inds)/P(2)).^2/4)-resmatsm(inds));
% % 
% % test = fitgaus3D(P0);
% % 
%  P = lsqnonlin(fitgaus3D, P0, [0 0 0], [100 100 100])
% % %result = gaussfun(P);
% % figure(1)
% % imshow(squeeze(test(:, rmax+1, :)), []);
% % figure(2)
% % imshow(squeeze(resmatsm(:, rmax+1, :)), []);
% 
% 
% %%
% 
% 
% 
% pts = [x(ind1)', y(ind1)'];
% 
% 
% 
% t1 = tree_from_points(box, pts1, 1000);
% c1 = xcor_tree(t1, t1, r, maskx, masky);
% 
% maxframe = size(data, 1)*size(data, 2);
% 
% c2 = 0;
% 
% parfor kk=1:n
%     switch how
%         case 'sequential'
%             ind_sub = kk:n:maxframe;
%         case 'random'
%             ind_sub = randperm(maxframe, floor(maxframe/n));
%     end
%     x2 = [data(ind_sub).x];
%     y2 = [data(ind_sub).y];
%     ind2 = inpolygon(x2,y2, maskx, masky);
%     pts2 = [x2(ind2)', y2(ind2)'];
%     t2 = tree_from_points(box, pts2, 1000);
%     c2 = c2+xcor_tree(t2, t2, r, maskx, masky)/n;
% end
% 
% 
% 
% c = c1-c2;
% 
% F = fit(rc(2:end)', c(2:end)', 'a1*exp(-x^2/2/c1^2)', 'startpoint', [1 bin]);
% 
% %plot(F, rc(2:end)', c(2:end)')
% 
% res = F.c1/sqrt(2);
% 
% info.c = c;
% info.c1 = c1;
% info.c2 = c2;
% info.F = F;
% info.rc = rc;
% info.r = r;
% info.how = how;
% 
% end
% 
