function options = grouping_default(units)

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
        
options.how = 'auto';
options.groupr = [];
options.units = units;
options.multfac = 2;


