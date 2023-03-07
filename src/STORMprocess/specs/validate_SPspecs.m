function [ specs ] = validate_SPspecs(specs, version)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

if ~isfield(specs, 'version')
    [specs.version] = deal(0);
end


while specs(1).version < version
    specs = arrayfun(@update_fitspecs, specs);
end

if ~all([specs.version] == version)
    error('Could not update fitting specs to this version. Is specs version newer than requested?')
end


function specs = update_fitspecs(specs)

fprintf('input fitting specs was version %f. updating now\n', specs.version);

switch specs.version
    case 0
        specs.fit_method = 'gaussianPSF';
        specs.spline_calibration_fname = [];
        
        specs.version = 0.1;      
end

% not used now, but could put back.
function good = check_STORMprocess_specs(specs)
if ~isstruct(specs)
    error('STORMprocess specs should be a struct');
end

nchan = numel(specs);
%fprintf('Checking specs for %d channels\n', nchan);

msg_missing = 'check_STORMproces_specs: missing field ';
msg_invalid = 'check_STORMproces_specs: invalid field ';

for ichan=1:nchan
    spec = specs(ichan);
    if ~isfield(spec,'nmax')
        error([msg_missing 'nmax']);
    elseif numel(spec.nmax) ~= 1
        error([msg_invalid 'nmax: must be scalar']);
    end

    if ~isfield(spec,'r_centroid')
        error([msg_missing 'r_centroid']);
    elseif numel(spec.r_centroid) ~= 1
        error([msg_invalid 'r_centroid: must be scalar']);
    end

    if ~isfield(spec,'r_neighbor')
        error([msg_missing 'r_neighbor']);
    elseif numel(spec.r_neighbor) ~= 1
        error([msg_invalid 'r_neighbor: must be scalar']);
    end

    if ~isfield(spec,'PSFwidth')
        error([msg_missing 'PSFwidth']);
    elseif numel(spec.PSFwidth) ~= 1
        error([msg_invalid 'PSFwidth: must be scalar']);
    end

    if ~isfield(spec,'mle_iters')
        error([msg_missing 'mle_iters']);
    elseif numel(spec.mle_iters) ~= 1
        error([msg_invalid 'mle_iters: must be scalar']);
    end

    if ~isfield(spec,'fitsigma')
        error([msg_missing 'fitsigma']);
    elseif numel(spec.fitsigma) ~= 1 || ~any(spec.fitsigma == [0,1]);
        error([msg_invalid 'fitsigma: must be 0 or 1']);
    end

    bg_methods = {'standard', 'true', 'unif'};
    if ~isfield(spec,'bg_method')
        error([msg_missing 'bg_method']);
    elseif ~any(strcmp(bg_methods, spec.bg_method))
        error([msg_invalid 'bg_method: ' spec.bg_method]);
    end

    bg_types = {'median', 'mean', 'selective', 'none'};
    if ~isfield(spec,'bg_type')
        error([msg_missing 'bg_type']);
    elseif ~any(strcmp(bg_types, spec.bg_type))
        error([msg_invalid 'bg_type: ' spec.bg_type]);
    end

    if ~isfield(spec,'movie_fnames')
        error([msg_missing 'movie_fnames']);
    elseif numel(spec.movie_fnames) < 1
        error([msg_invalid 'movie_fnames: must be non-empty']);
    end

    if ~isfield(spec,'channel_dims')
        error([msg_missing 'channel_dims']);
    elseif numel(spec.channel_dims) ~= 4
        error([msg_invalid 'channel_dims: must be non-empty']);
    end

    if ~isfield(spec,'thresh')
        error([msg_missing 'thresh']);
    elseif numel(spec.thresh) ~= 1
        error([msg_invalid 'thresh: must be scalar']);
    end
end

good = 1;

        
        
        
        

