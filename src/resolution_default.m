function options = resolution_default(units, fit_method)

fac = 1;
if nargin < 1
    units = 'px';
end

if nargin < 2
    fit_method = 'gaussianPSF';
end

switch units
    case 'nm'
        fac = 1;
    case {'pix', 'px', 'pixel', 'pixels'}
        fac = 1/160;
        units = 'px';
    case 'um'
        fac = 1e-3;
end
   

switch fit_method
    case 'gaussianPSF'
        options.maxr = 500*fac;
        options.how = 'sequential';
        options.niter = 5;
        options.binsize = 10*fac;
        options.units = units;
    case 'spline'
        options.maxr = 200*fac;
        options.range = [];
        options.binsize = 25*fac;
        options.niter = 5;
        options.units = units;
end
        
        

