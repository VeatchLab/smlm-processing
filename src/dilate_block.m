function dilated = dilate_block(data, record, units)
% Do a dilation step

if nargin < 3
    units = 'nm'; % convert to nm by default
end

oldunits = data.units;

oldfac = getfac(oldunits, record);
newfac = getfac(units, record);

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
    dilated.data = cellfun(@(d) dilatepts(d, newfac/oldfac), data.data,...
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
