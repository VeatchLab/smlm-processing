function [fs, allres, errors, centerx, centery] = fit_corr_function(g, xc, yc, goodbins, tcenters, rmax, show_diagnostics)
% [FS, ALLRES, ERRORS, CENTERX, CENTERY] = FIT_CORR_FUNCTION(G, XC, YC, GOODBINS, TCENTERS, RMAX, SHOW_DIAGNOSTICS)

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

% make a fittype for the gaussian
fitgauss = fittype(...
    @(A,s1,s2,x0,y0,c,x,y) A*exp(-((x0-x).^2/(2*s1.^2) + (y0-y).^2/(2*s2.^2)))+c,...
    'coefficients', {'A', 's1', 's2', 'x0', 'y0', 'c'},...
    'indep', {'x', 'y'}, 'dep', 'z');
[xmesh,ymesh] = meshgrid(xc, yc);
tofit = goodbins == 1;

fgo = fitoptions(fitgauss);
fgo.StartPoint = [1,20,30,0,0 0];
fgo.Lower = [0,0,0,-rmax,-rmax,-inf];
fgo.Upper = [Inf,rmax,rmax,rmax,rmax,inf];

for l=1:numel(tcenters)-1
    
    slope = g(:, :, l)-g(:, :, end);
    slope = slope/max(slope(:));
    
    f = fit([xmesh(tofit) ymesh(tofit)], slope(tofit), fitgauss, fgo);
    fs{l} = f;
    centerx(l) = f.x0;
    centery(l) = f.y0;
    
    CI = confint(fs{l}, .68);
    d = .5*(diff(CI, 1)); % standard errors
    allres(l) = sqrt(1/2*f.s2^2 + f.x0^2 + f.y0^2);
    errors(l) = sqrt((f.s2*d(2))^2+(2*f.x0*d(3))^2+(2*f.y0*d(4))^2)/allres(l);
    
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
