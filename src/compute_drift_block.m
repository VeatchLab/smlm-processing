function [aligned, drift_info] = compute_drift_block(data, record)

timing = zeros(1, numel(data.data{1}));
nframes = size(data.data{1},2);
mdata = record.metadata;
for i = 1:size(data.data{1},1)
    dvec = datevec(mdata(i).start_time);
    Tstart = 60*[0 0 60*24 60 1 1/60]*dvec';
    timing((1:nframes) + (i-1)*nframes) = Tstart + ...
                                                mdata(i).timestamp;
end

nchannels = numel(data.data);

driftspecs = record.driftspecs;
cull_channel = driftspecs.channel;

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
