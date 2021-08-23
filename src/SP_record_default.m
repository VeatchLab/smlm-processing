function record =  SP_record_default(nchan, fit_type, varargin)

if nargin < 1
    nchan = 2; % dualview by default
end

record.cullspecs = repmat({cull_defaults(fit_type)}, 1, nchan);
record.dv_transform_fname = '';

% new in version 0.1
if nchan == 1
    record.tform_channel = [];
else
    record.tform_channel = 2;
end

record.driftspecs = [];
record.drift_info = [];
record.cullinds = cell(size(record.cullspecs));
record.fits_fname = 'fits.mat';
record.transformed_fname = '';
record.dilated_fname = 'transformed.mat';
record.culled_fname = '';
record.final_fname = 'final.mat';
record.fit_type = fit_type;

% new in version 0.2
record.grouped_fname = '';
record.res_specs = [];
record.grouping_specs = grouping_default('nm');

record.version = 0.2;

% Process arguments
i = find(strcmp(varargin, 'transform'));
if ~isempty(i)
    record.dv_transform_fname = varargin{i + 1};
    % extra args will go into stormprocess specs
    inds = 1:numel(varargin);
    inds = (inds ~= i & inds ~= i+1);
    SP_args = varargin(inds);
else
    record.dv_transform_fname = '';
    SP_args = varargin;
end

switch fit_type
    case 'gaussianPSF'
        if nchan == 1
            record.SPspecs = default_specs_singleview(SP_args{:});
        elseif nchan == 2
            record.SPspecs = default_specs_dualview(SP_args{:});
        end
    case 'spline'
        record.SPspecs = default_specs_spline([], SP_args{:});
end
