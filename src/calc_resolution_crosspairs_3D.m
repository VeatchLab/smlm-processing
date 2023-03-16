function [res, info] = calc_resolution_crosspairs_3D(data, record, options)
% Calculates the 3D resolution as a function of the time lapse tau between
% pairs of localizations. Computes this separately based on the 2D cross
% sections x-y, x-z, and y-z. Used to evaluate the drift correction.

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
z = [data(:).z];

% find t
count = 1;
for i = 1:numel(data)
    t(count:count+length(data(i).x)-1) = timevec(frames(i));
    count = count + length(data(i).x);
end

taumin = frame_time/10; % should be > 0 so localizations aren't paired with themselves
taumax = max(t);

noutmax = 2e8;
[dx, dy, dz, dt] = crosspairs_3D(x, y, z, t, x, y, z, t, rmax, taumin, taumax, noutmax);
if numel(dx) == noutmax
    warning('Too many pairs! Consider taking a smaller number of data frames or lowering rmax.')
end

% do 2D cross sections
[g_xy, xc, yc, goodbins, tedge, tedge_sec] = compute_corr_function(dx, dy, dt, data, x, y, Npts, rmax, binsize, timevec, frame_time);
g_xz = compute_corr_function(dx, dz, dt, data, x, z, Npts, rmax, binsize, timevec, frame_time);
g_yz = compute_corr_function(dy, dz, dt, data, y, z, Npts, rmax, binsize, timevec, frame_time);

zc = xc; % for now, may change if zmax is larger;

for i=1:numel(tedge)-1
    tcenters(i) = mean([tedge_sec(i),tedge_sec(i+1)]);
    dtcenters(i) = tcenters(i)-tedge_sec(i);
end

g_xy(isnan(g_xy(:))) = 1;
g_xz(isnan(g_xz(:))) = 1;
g_yz(isnan(g_yz(:))) = 1;

[fs_xy, allres_xy, errors_xy, centerx_xy, centery_xy] = fit_corr_function(g_xy, xc, yc, goodbins, tcenters, rmax, options.show_diagnostics);
[fs_xz, allres_xz, errors_xz, centerx_xz, centerz_xz] = fit_corr_function(g_xz, xc, zc, goodbins, tcenters, rmax, options.show_diagnostics);
[fs_yz, allres_yz, errors_yz, centery_yz, centerz_yz] = fit_corr_function(g_yz, yc, zc, goodbins, tcenters, rmax, options.show_diagnostics);

figure; H_xy = errorbar(tcenters(1:end-1), allres_xy, errors_xy, 'o-', 'MarkerFaceColor', 'auto');
set(gca, 'XScale', 'log')
xlabel('\tau (s)')
ylabel('Resolution (nm)')
hold on; H_xz = errorbar(tcenters(1:end-1), allres_xz, errors_xz, 'o-', 'MarkerFaceColor', 'auto');
hold on; H_yz = errorbar(tcenters(1:end-1), allres_yz, errors_yz, 'o-', 'MarkerFaceColor', 'auto');
legend('X-Y', 'X-Z', 'Y-Z')

% save info
info.tcenters = tcenters;

info.fs_xy = fs_xy;
info.fs_xz = fs_xz;
info.fs_yz = fs_yz;

info.allres_xy = allres_xy;
info.allres_xz = allres_xz;
info.allres_yz = allres_yz;

info.errors_xy = errors_xy;
info.errors_xz = errors_xz;
info.errors_yz = errors_yz;

info.centerx_xy = centerx_xy;
info.centery_xy = centery_xy;
info.centerx_xz = centerx_xz;
info.centery_xz = centerz_xz;
info.centery_yz = centery_yz;
info.centerz_yz = centerz_yz;

% compute single resolution figure
res(1) = median(allres_xy); % not sure about the best final resolution figure
res(2) = median(allres_xz + allres_yz)/2;
