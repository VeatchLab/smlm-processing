function [res, info] = calc_resolution_crosspairs(data, record, options)
% Calculates the 2D resolution as a function of the time lapse tau between
% pairs of localizations. Used to evaluate the drift correction.

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

mdata = record.metadata;
frame_time = record.metadata.frame_time;
nframes = numel(data);
frames = 1:nframes;

Npts = options.Npts;
rmax = options.rmax;
binsize = options.binsize;

% Convert times to s from start of experiment.
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

x = [data(:).x];
y = [data(:).y];

% find t
count = 1;
for i = 1:numel(data)
    t(count:count+length(data(i).x)-1) = timevec(frames(i));
    count = count + length(data(i).x);
end

taumin = frame_time/10; % should be > 0 so localizations aren't paired with themselves
taumax = max(t);

noutmax = 2e8;
[dx, dy, dt] = crosspairs(x, y, t, x, y, t, rmax, taumin, taumax, noutmax);
if numel(dx) == noutmax
    warning('Too many pairs! Consider taking a smaller number of data frames or lowering rmax.')
end

[g, xc, yc, goodbins, tedge, tedge_sec] = compute_corr_function(dx, dy, dt, data, x, y, Npts, rmax, binsize, timevec, frame_time);

g(isnan(g(:))) = 1;

for i=1:numel(tedge)-1
    tcenters(i) = mean([tedge_sec(i),tedge_sec(i+1)]);
    dtcenters(i) = tcenters(i)-tedge_sec(i);
end

[fs, allres, errors, centerx, centery] = fit_corr_function(g, xc, yc, goodbins, tcenters, rmax, options.show_diagnostics);

figure; H = errorbar(tcenters(1:end-1), allres, -errors, errors, 'o-', 'MarkerFaceColor', 'auto');
set(gca, 'XScale', 'log')
xlabel('\tau (s)')
ylabel('Resolution (nm)')

% save info
info.tcenters = tcenters;
info.fs_xy = fs;
info.allres_xy = allres;
info.errors_xy = errors;
info.centerx_xy = centerx;
info.centery_xy = centery;
info.g = g;
info.xc = xc;
info.yc = yc;

% compute single resolution figure
res = median(allres); % not sure about the best final resolution figure
