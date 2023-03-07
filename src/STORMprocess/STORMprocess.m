function [data,bginfo,metadata] = STORMprocess(all_specs)
all_specs = check_specs(all_specs);

% There's a specs for each channel
nchan = numel(all_specs);

% a fit queue for each channel
fq = cell(1,nchan);
data = cell(1,nchan);
bginfo = cell(1,nchan);
for ichan = 1:nchan
    fq{ichan} = FitQueue(all_specs(ichan)); %% need to update FitQueue
end

% Check kernel execution timeout and issue warning
g = gpuDevice;
if g.KernelExecutionTimeout
    warning('KernelExecutionTimeout is on: This can cause errors if maxfits parameter is too high');
end

% collate movies from each channel. 'stable' option means keep order
all_movies = unique([all_specs.movie_fnames],'stable');
nmov = numel(all_movies);

ts = get_timestamp(all_movies{1});
metadata = repmat(ts, 1, nmov);

nmovchan = arrayfun(@(x) numel(x.movie_fnames), all_specs);
imovchan = ones(1,nchan);

% whichchannels(imov, ichan) is True iff imov has data for ichan
whichchannels = false(nmov, nchan);
for imov = 1:numel(all_movies)
    f = all_movies{imov};
    for ichan = find(imovchan <= nmovchan)
        fchan = all_specs(ichan).movie_fnames{imovchan(ichan)};
        if strcmp(f,fchan) % channel ichan has this movie
            imovchan(ichan) = imovchan(ichan) + 1;
            whichchannels(imov,ichan) = true;
        end
    end
end

% Loop over movies
for imov = 1:nmov
    % Get movie filename
    movie_fname = all_movies{imov};
    fprintf('%d: %s, ', imov, movie_fname);
    if mod(imov,5) == 0
        fprintf('\n');
    end
    %fprintf('Processing movie %d: %s\n', imov, movie_fname);

    % get channel indices that use this movie
    channels = find(whichchannels(imov,:));
    camera = all_specs(channels(1)).camera_specs;

    % read movie
    Istack = readTiffFast(movie_fname);
    timestamp = get_timestamp(movie_fname);
    cropdims = timestamp.cropdims;
    metadata(imov) = timestamp;
    
    % correct order of cropdims (fix this if timestamp changes)
    % timestamp.cropdims = timestamp.cropdims([3 4 1 2]);

    % calibrate movie
    if strcmp(camera.type, 'scmos')
        [Istack, vars] = calibrate_scmos(Istack, camera, timestamp);
    else
        Istack = calibrate(Istack, camera, timestamp);
    end

    % crop movie frames to the part for each channel
    Iall = cell(1,nchan);
    % shifts due to camera crop of movie indices compared to camera indices
    if timestamp.rot90
        dx = cropdims(1) - 1; 
        dy = 512 - cropdims(4);
    else
        dx = cropdims(3) - 1;
        dy = cropdims(1) - 1;
    end
    
    for ichan = channels
        specs = all_specs(ichan);
        chandims = specs.channel_dims; % dimensions for channel
        % left, right, top, bottom indices, in movie index units
        if timestamp.rot90
            l = max(chandims(1), cropdims(1)) - dx;
            r = min(chandims(2), cropdims(2)) - dx;
            t = max(chandims(3), cropdims(3)) - cropdims(3) + 1;
            b = min(chandims(4), cropdims(4)) - cropdims(3) + 1;
        else
            l = max(chandims(1), cropdims(3)) - dx;
            r = min(chandims(2), cropdims(4)) - dx;
            t = max(chandims(3), cropdims(1)) - dy;
            b = min(chandims(4), cropdims(2)) - dy;
        end

        % take care of paired frames
        if isfield(specs, 'paired_frames') && specs.paired_frames
            Iall{ichan} = Istack(t:b, l:r, 1:(end-1)) + Istack(t:b, l:r, 2:end);
        else
            Iall{ichan} = Istack(t:b,l:r,:);
        end
    end
    clear Istack; % Istack doesn't need to be in memory anymore

    for ichan = channels % loop over channels that use this movie
        %fprintf('\tSegmentation for channel %d\n', ichan);

        % Specs for this channel:
        specs = all_specs(ichan);

        % segment and compute background
        bginfo{ichan}(imov) = segment(Iall{ichan},specs);
        coords = bginfo{ichan}(imov).pts;

        % make psfstacks
        switch specs.bg_type
            case 'median'
                Ibg = bginfo{ichan}(imov).Imed;
            case 'mean'
                Ibg = bginfo{ichan}(imov).Imean;
            case 'selective'
                Ibg = bginfo{ichan}(imov).Isel;
            case 'none'
                Ibg = zeros(size(Iall{ichan}(:,:,1)));
            otherwise
                error(['no such bg_type: ', specs.bg_type]);
        end
        dL = specs.r_centroid;
        if strcmp(specs.fit_method, 'scmos')
            [psfstack,ninframe,otherstacks] = makepsfstack(Iall{ichan}, coords, dL, Ibg, vars);
        else
            [psfstack,ninframe,otherstacks] = makepsfstack(Iall{ichan}, coords, dL, Ibg);
        end

        % optionally dispatch fitting
        %fprintf('\tStarting fitting for channel %d\n', ichan);
        nframes = numel(ninframe);
        movinds = [repmat(imov,nframes,1), (1:nframes)', ninframe'];
        c = vertcat(coords{:});
        c = c + repmat([dx, dy], size(c,1), 1); % Add shift due to camera crop
        fq{ichan}.add(psfstack,otherstacks, c, movinds);
        fq{ichan}.collect();
    end
end

% wait for remaining fits
for ichan = 1:nchan
    fq{ichan}.waitall();
    data{ichan} = fq{ichan}.extract();
end

% add discvals from bginfo
for imov = 1:nmov
    % Only do channels that were imaged in this movie
    channels = find(whichchannels(imov,:));
    for ichan = channels
        nframe = size(data{ichan},2);
        for iframe = 1:nframe
            data{ichan}(imov, iframe).discval = bginfo{ichan}(imov).discvals{iframe};
        end
    end
end

fprintf('\n'); % make sure prompt is on new line

function specs = check_specs(specs)
% if arg is a filename
if (isa(specs, 'char') && (numel(dir(specs)) || numel(dir([specs, '.mat']))))
    load(specs, 'specs');
end

nchan = numel(specs);
%fprintf('Checking specs for %d channels\n', nchan);

msg_missing = 'check_specs: missing field ';
msg_invalid = 'check_specs: invalid field ';

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
