function dilated = dilate_block(data, record, units)
% Do a dilation step

if nargin < 3
    units = 'nm'; % convert to nm by default
end

oldunits = data.units;

oldfac = getfac(oldunits, record);
newfac = getfac(units, record);

dilated.data = cellfun(@(d) dilatepts(d, newfac/oldfac), data.data,...
    'UniformOutput', false);
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
        cspecs = record.SPspecs.cspecs;
        fac = cspecs.magnification / cspecs.pixel_size; % pixels per micron
    otherwise
        error('unknown units, can''t dilate')
end
