function [aligned, drift_info] = compute_drift_block(data, record)

nchannels = numel(data.data);

driftspecs = record.driftspecs;
cull_channel = driftspecs.channel;

% load notification file, if one exists
if exist(fullfile(pwd,'activenotif.mat'), 'file')
    activenotif = load('activenotif.mat');
elseif exist(fullfile(pwd,'activenotif.txt'), 'file')
    activenotif = load('activenotif.txt');
else
%     warning(strcat('No active notification file found in this folder. Please rename to', ...
%         ' activenotif.mat if one exists. Proceeding assuming the ZDC was off.'))
    activenotif = [];
end
       
if ~isfield(driftspecs, 'delta_narrow_ratio')
    driftspecs = drift_default_meanshift();
    driftspecs = driftspecs_meanshift_gui(driftspecs);
end

if driftspecs.skip_correction
    aligned.data{cull_channel} = data.data{cull_channel};
    drift_info = [];
    aligned.date = datetime;
    aligned.produced_by = 'compute_drift';
    aligned.units = 'nm';
    aligned.drift_info = drift_info;
    return
end

if driftspecs.correctz
    [aligned.data{cull_channel}, drift_info] = compute_drift_meanshift_3D(data.data{cull_channel}, driftspecs, record, activenotif);
else
    [aligned.data{cull_channel}, drift_info] = compute_drift_meanshift_2D(data.data{cull_channel}, driftspecs, record);
end


if nchannels > 1
    for i=find((1:nchannels) ~= cull_channel)
        [aligned.data{i}] = apply_shifts(data.data{i}, drift_info);
    end
end

aligned.date = datetime;
aligned.produced_by = 'compute_drift';
aligned.units = 'nm';
aligned.drift_info = drift_info;
