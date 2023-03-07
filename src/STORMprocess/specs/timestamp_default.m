function ts = timestamp_default(movie_fname, varargin)


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
