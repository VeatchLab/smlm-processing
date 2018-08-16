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
%options.align_to_image_flag= 0;
%options.align_to_TIR_flag= 0;
%options.display_results_flag= 1;
%options.TIR_filename = [];
%options.image_for_alignment = [];
%options.bounding_box= [];%[0 0 512 512];
