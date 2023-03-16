function ts = get_timestamp(movie_fname)
% TS = GET_TIMESTAMP(MOVIE_FNAME)

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

if ~ischar(movie_fname)
    error('get_timestamp: bad input arg, should be a string (containing a movie name)');
end

% use a regular expression to get the base name of the movie
tokencell = regexp(movie_fname, '(.*)\.tif|(.*)', 'tokens');
ts_fname = [tokencell{1}{1}, '_timestamp.mat'];

% check it's a file
if isempty(dir(ts_fname))
    % fail gracefully?
    ts = timestamp_default(movie_fname);
else
    ts = load(ts_fname);
    ts.fname = ts_fname;
end

% This is where we should take care of different versions if we ever have to
if ~isfield(ts, 'version')
    ts.version = 0;
end

if ts.version < 1
    ts.rot90 = 1;
    ts.version = 1;
end

if ts.version < 2
    ts.type = 'emccd';
    ts.version = 2;
end

if ts.type == 'scmos'
    ts = fix_scmos_timestamp(ts);
end
