function options = resolution_default(units)

fac = 1;
if nargin < 1
    units = 'px';
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
   
options.Npts = 12;
options.rmax = 200*fac;
options.binsize = 5*fac;
options.units = units;
options.show_diagnostics = 0;
options.version = 0.1;

end