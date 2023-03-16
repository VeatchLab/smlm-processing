function ts = timestamp_default(movie_fname, varargin)
% TS = TIMESTAMP_DEFAULT(MOVIE_FNAME, VARARGIN)

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


ts.Speed_value = 0;
ts.preamp_gain = 2;
ts.EMCCD_gain = 100;

I = imread(movie_fname, 1);
w = size(I,2);
h = size(I,1);

ts.cropdims = [1 h 1 w];

% ts.rot90 = 1; % this is for old dv data
ts.rot90 = 0; % this is more appropriate for random data
ts.version = 1;
