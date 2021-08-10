function [fs, allres, errors, centerx, centery] = fit_corr_function(g, xc, yc, goodbins, tcenters, rmax, show_diagnostics)

% make a fittype for the gaussian
fitgauss = fittype(...
    @(A,s,x0,y0,c,x,y) A*exp(-((x0-x).^2 + (y0-y).^2)/(2*s.^2))+c,...
    'coefficients', {'A', 's', 'x0', 'y0', 'c'},...
    'indep', {'x', 'y'}, 'dep', 'z');
[xmesh,ymesh] = meshgrid(xc, yc);
tofit = goodbins == 1;

fgo = fitoptions(fitgauss);
fgo.StartPoint = [1,20,0,0 0];
fgo.Lower = [0,0,-rmax,-rmax,-inf];
fgo.Upper = [Inf,rmax,rmax,rmax,inf];

for l=1:numel(tcenters)-1
    
    slope = g(:, :, l)-g(:, :, end);
    slope = slope/max(slope(:));
    
    f = fit([xmesh(tofit) ymesh(tofit)], slope(tofit), fitgauss, fgo);
    fs{l} = f;
    centerx(l) = f.x0;
    centery(l) = f.y0;
    
    CI = confint(fs{l}, .68);
    d = .5*(diff(CI, 1)); % standard errors
    allres(l) = sqrt(1/2*f.s^2 + f.x0^2 + f.y0^2);
    errors(l) = sqrt((f.s*d(2))^2+(2*f.x0*d(3))^2+(2*f.y0*d(4))^2)/allres(l);
    
    if show_diagnostics
        % show differences of corr functions
        figure(1);
        imagesc(xmesh(:), ymesh(:), slope)
        pause(.5)
        
        % show points plotted along with fits
        figure(2);
        plot(f, [xmesh(tofit) ymesh(tofit)], slope(tofit))
        pause(.5)
    end
end