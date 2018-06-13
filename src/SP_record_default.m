function record =  SP_record_default(nchan, varargin)

if nargin < 1
    nchan = 2; % dualview by default
end

if nchan == 1
    record.SPspecs = default_specs_singleview(varargin{:});
elseif nchan == 2
    record.SPspecs = default_specs_dualview(varargin{:});
end
record.cullspecs = repmat({cull_defaults()}, 1, nchan);
record.dv_transform_fname = '';

% new in version 0.1
if nchan == 1
    record.tform_channel = [];
else
    record.tform_channel = 2;
end

record.driftspecs = drift_default('nm');
record.drift_info = [];
record.cullinds = cell(size(record.cullspecs));
record.fits_fname = 'fits.mat';
record.transformed_fname = '';
record.dilated_fname = 'transformed.mat';
record.culled_fname = '';
record.final_fname = 'final.mat';

record.version = 0.1;
