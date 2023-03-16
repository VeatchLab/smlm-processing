function options = drift_default(units, fit_type)
% OPTIONS = DRIFT_DEFAULT(UNITS, FIT_TYPE)

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


