function dilated = dilate_block(data, record, units)
% DILATED = DILATE_BLOCK(DATA, RECORD, UNITS)

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
% DO A DILATION STEP

if nargin < 3
    units = 'nm'; % convert to nm by default
end

oldunits = data.units;

oldfac = getfac(oldunits, record);
newfac = getfac(units, record);

dilatefac = newfac/oldfac;

SPspecs = record.SPspecs;

if strcmp(SPspecs(1).fit_method, 'spline') % handle z case separately
    spline_cal = load(SPspecs.spline_calibration_fname, 'actualz', 'beginheight');
    actualz = spline_cal.actualz;
    beginheight = spline_cal.beginheight;
    
    if actualz(1) > 0
        actualz = actualz - beginheight;
    end
    dilated.data = cellfun(@(d) dilatepts(d, dilatefac, 1e3*actualz), data.data,...
        'UniformOutput', false);
else
    dilated.data = cellfun(@(d) dilatepts(d, dilatefac), data.data,...
        'UniformOutput', false);
end
dilated.units = units;
dilated.date = datetime;
dilated.produced_by = 'dilatepts';


function fac = getfac(units, record)
% a dilation factor based on microns
switch units
    case 'nm'
        fac = 1e3;
    case 'um'
        fac = 1;
    case 'px'
        cspecs = record.SPspecs.camera_specs;
        fac = cspecs.magnification / cspecs.pixel_size; % pixels per micron
    otherwise
        error('unknown units, can''t dilate')
end
