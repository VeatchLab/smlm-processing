function [res, info] = calc_resolution_spacetime(data, record, options)
% CALC_RESOLUTION_SPACETIME Calculate resolution using spacetime correlation analysis
%   [RES, INFO] = CALC_RESOLUTION_SPACETIME(DATA, RECORD, OPTIONS) calculates
%   the resolution using the new spacetime correlation approach.
%
%   Inputs:
%       data - cell array of localization data
%       record - record structure with metadata
%       options - resolution options structure
%
%   Outputs:
%       res - resolution estimate
%       info - additional information

% Extract metadata
mdata = record.metadata;
frame_time = record.metadata.frame_time;
nframes = numel(data);
frames = 1:nframes;

% Convert times to s from start of experiment
framespermovie = size(data, 2);
movienum = numel(data)/framespermovie;
timevec = zeros(nframes, 1);
moviei_start_time = zeros(movienum, 1);
for i = 1:movienum
    moviei_start_time(i) = 60 * 60 * 24 * rem(mdata(i).start_time, 1);
    timevec((1:framespermovie) + (i - 1) * framespermovie) = frame_time * (1:framespermovie) + ...
        (moviei_start_time(i) - moviei_start_time(1));
end

% Put the data in the right shape
if size(data,2) ~= numel(data)
    data = reshape(data', 1, numel(data));
end

% Extract x, y coordinates and times
x = [data(:).x];
y = [data(:).y];

% Find t
count = 1;
for i = 1:numel(data)
    t(count:count+length(data(i).x)-1) = timevec(frames(i));
    count = count + length(data(i).x);
end

% Create data structure for spacetime_resolution
spacetime_data = struct();
spacetime_data.x = x;
spacetime_data.y = y;
spacetime_data.t = t;

% Set default options if not provided
if ~isfield(options, 'NTauBin')
    options.NTauBin = 10;
end
if ~isfield(options, 'RMax')
    options.RMax = 1000;
end
if ~isfield(options, 'BinSize')
    options.BinSize = 10;
end

% Run spacetime resolution calculation
[corrdata, params] = spacetime_resolution(spacetime_data, ...
    'NTauBin', options.NTauBin, ...
    'RMax', options.RMax, ...
    'BinSize', options.BinSize);

% Extract resolution estimate
res = corrdata.S;

% Create info structure
info.corrdata = corrdata;
info.params = params;
info.tau = corrdata.taubincenters;
info.r = corrdata.r;
info.cWA = corrdata.cWA;
info.nDg = corrdata.nDg;
info.s = corrdata.s;
info.confint = corrdata.confint;

% Create plots similar to the original calculate_resolution.m
figure;
plot(corrdata.r, corrdata.cWA);
tau = corrdata.taubincenters;
lh = legend(arrayfun(@num2str, tau, 'UniformOutput', false));
title(lh,'\tau (s)');
xlabel('r (nm)');
ylabel('g(r, \tau)');
set(gca, 'YScale', 'log');
title('Correlation functions for each tau bin');

figure;
plot(corrdata.r, corrdata.nDg);
lh = legend(arrayfun(@num2str, tau(1:end-1), 'UniformOutput', false));
title(lh,'\tau (s)');
xlabel('r (nm)');
ylabel('g(r, \tau)');
title('Normalized correlation function differences');

figure;
errorbar(tau(1:end-1), corrdata.s, corrdata.confint, 'o-');
title(sprintf('Average resolution is %.1f nm', corrdata.S));
xlabel('\tau (s)', 'FontSize', 16);
ylabel('resolution estimate (nm)', 'FontSize', 16); 