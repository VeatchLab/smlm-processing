function options = drift_default(units, fit_type)

if isstruct(units) % they passed in data
    data = units.data;
    units = units.units;
    hasdata = true;
else
    hasdata = false;
end

fac = 1;
if nargin < 1
    units = 'px';
end

if nargin < 2
    fit_type = 'gaussianPSF';
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
        
options.channel = 1;
      
if hasdata
    options.npoints_for_alignment = size(data{1},1);
    options.nframes_per_alignment = size(data{1},2);
else
    options.npoints_for_alignment= 10;
    options.nframes_per_alignment= 500;
end
options.interp_method= 'linear';
options.psize_for_alignment= 30*fac;
options.rmax_shift = 2000*fac;
options.rmax= 400*fac;
options.sigma_startpt = 50*fac;
options.update_reference_flag= true;
options.include_diagnostics = true;
options.units = units;
switch fit_type
    case 'gaussianPSF'
        options.correctz = 0;
    case 'spline'
        options.correctz = 1;
end

% new driftspecs for the mean shift algorithm
options.outlier_error = 50*fac;
options.delta_broad = 100*fac;
options.delta_narrow_ratio = 3;
options.calc_error = 1;
options.broadsweep = 0;
options.fix_nframes_per_alignment = 1;
options.skip_correction = 0;
options.version = 0.1;


