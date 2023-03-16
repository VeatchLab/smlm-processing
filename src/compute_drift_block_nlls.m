function [aligned, drift_info] = compute_drift_block_nlls(data, record)
% [ALIGNED, DRIFT_INFO] = COMPUTE_DRIFT_BLOCK_NLLS(DATA, RECORD)

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

nchannels = numel(data.data);

driftspecs = record.driftspecs;
cull_channel = driftspecs.channel;

timing = 1:numel(data.data{cull_channel});
nframes = size(data.data{cull_channel},2);
mdata = record.metadata;
for i = 1:size(data.data{cull_channel},1)
    if isfield(mdata(i), 'start_time')
        dvec = datevec(mdata(i).start_time);
        Tstart = 60*[0 0 60*24 60 1 1/60]*dvec';
        timing((1:nframes) + (i-1)*nframes) = Tstart + ...
                                                mdata(i).timestamp;
    end
end

[aligned.data{cull_channel}, drift_info] = compute_drift(data.data{cull_channel}, timing, driftspecs);

figure
errorbar(drift_info.xshift, drift_info.yshift, ...
    -drift_info.dyshift, drift_info.dyshift, ...
    -drift_info.dxshift, drift_info.dxshift);
axis equal

if nchannels > 1
    for i=find((1:nchannels) ~= cull_channel)
        [aligned.data{i}] = apply_shifts(data.data{i}, drift_info);
    end
end

aligned.date = datetime;
aligned.produced_by = 'compute_drift';
aligned.units = 'nm';
aligned.drift_info = drift_info;
