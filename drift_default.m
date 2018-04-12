function options = drift_default(units)

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
        
      
options.npoints_for_alignment= 10;
options.nframes_per_alignment= 500;
options.interp_method= 'linear';
options.psize_for_alignment= 10*fac;
options.rmax_shift = 1000*fac;
options.rmax= 200*fac;
options.update_reference_flag= true;
options.include_diagnostics = true;
%options.align_to_image_flag= 0;
%options.align_to_TIR_flag= 0;
%options.display_results_flag= 1;
%options.TIR_filename = [];
%options.image_for_alignment = [];
%options.bounding_box= [];%[0 0 512 512];
