function good = check_STORMprocess_specs(specs)
% GOOD = CHECK_STORMPROCESS_SPECS(SPECS)

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
