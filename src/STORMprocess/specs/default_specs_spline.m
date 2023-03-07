function specs = default_specs_spline(calibFILE, varargin)
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

specs(1).channel_dims = [1,512,1,512];

specs.movie_fnames = glob_fnames('mov*.tif'); % good starting place?

specs.thresh = 1.5;

specs.r_centroid = 8;
specs.r_neighbor = 12;
specs.r_mingroup = 4;
specs.r_maxgroup = 11;

specs.PSFwidth = 1.2;

specs.fittype = 'correct';
specs.bg_method = 'standard';
specs.bg_type ='median';% 'selective';

specs.fitsigma = 1;
specs.nmax = 10000;
specs.mle_iters = 20;

specs.camera_specs = cameraspec_default();

specs.fit_method = 'spline';
specs.spline_calibration_fname = calibFILE;

specs.version = 0.1;


if numel(varargin)/ 2 ~= round(numel(varargin)/2)
    error('default_specs_singleview: args need to come in pairs!!');
end

for i=1:(numel(varargin)/2)
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
