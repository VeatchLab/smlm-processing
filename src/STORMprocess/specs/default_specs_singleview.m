function specs = default_specs_singleview(varargin)
% DEFAULT_SPECS_SINGLVIEW return a struct with specs for STORMprocess
%    specs = DEFAULT_SPECS_SINGLVIEW() uses defaults for all fields.
%       MOVIE_FNAMES is filled using the glob 'mov*.tif'. Other parameters are
%       chosen to be be good starting points.
%
%    specs = DEFAULT_SPECS_SINGLVIEW('PARAM1', VALUE1, ...) As above, but use
%       VALUE1 for specs.PARAM1.
%
%    specs = DEFAULT_SPECS_SINGLVIEW(..., 'MovieRE', GLOB, ...) As above, but
%       use GLOB to glob for MOVIE_FNAMES
%
%    See also DEFAULT_SPECS_DUALVIEW, STORMPROCESS

specs = struct();

specs.version = 0.1;

specs(1).channel_dims = [1,512,1,512];

specs.movie_fnames = glob_fnames('mov*.tif'); % good starting place?

specs.thresh = 2;

specs.r_centroid = 3;
specs.r_neighbor = 5.5;
specs.PSFwidth = 1.2;

specs.fittype = 'correct';
specs.fit_method = 'gaussianPSF';
specs.bg_method = 'standard';
specs.bg_type = 'selective';

specs.fitsigma = 1;
specs.nmax = 100000;
specs.mle_iters = 10;

specs.r_mingroup = [];
specs.r_maxgroup = [];
specs.spline_calibration_fname = [];

specs.camera_specs = cameraspec_default();

if nargin / 2 ~= round(nargin/2)
    error('default_specs_singleview: args need to come in pairs!!');
end

for i=1:(nargin/2)
field = varargin{2*i - 1};
value = varargin{2*i};

    if isfield(specs, field)
        % put the value in the field, if valid
        specs.(field) = value;
    elseif strcmp(field, 'MovieRE')
        % fnames that match pattern given as argument
        specs.movie_fnames = glob_fnames(value);
    else
        % Bad field value, error
        error(['default_specs_dualview: not a field name: ' field]);
    end
end
