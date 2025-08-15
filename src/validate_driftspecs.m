function driftspecs = validate_driftspecs(driftspecs, version, datastruct)
% VALIDATE_DRIFTSPECS read driftspecs as correct version
%    VALIDATE_DRIFTSPECS(DRIFTSPECS, VERSION) update DRIFTSPECS structure to desired VERSION
%
if ~isfield(driftspecs, 'version')
    driftspecs.version = 0;
end

while driftspecs.version < version
    driftspecs = update_driftspecs(driftspecs, datastruct);
end

if driftspecs.version ~= version
    error('Could not update driftspecs to this version. Is driftspecs version newer than requested?')
end


function driftspecs = update_driftspecs(driftspecs, datastruct)
% UPDATE_driftspecs update the driftspecs struct from its current version to the next one
fprintf('input driftspecs was version %f. updating now\n', driftspecs.version);
% retain settings from previous version of driftspecs
dold = driftspecs;

% Check if data has z field - handle both struct arrays and matrices
if isfield(datastruct, 'data') && ~isempty(datastruct.data) && iscell(datastruct.data)
    if isstruct(datastruct.data{1}) && ~isempty(datastruct.data{1}) && isfield(datastruct.data{1}(1), 'z')
        driftspecs = drift_default(datastruct, 'spline');
    else
        driftspecs = drift_default(datastruct, 'gaussianPSF');
    end
else
    % Default to gaussianPSF if we can't determine the data structure
    driftspecs = drift_default(datastruct, 'gaussianPSF');
end

fs = fieldnames(dold);
for i = 1:numel(fs)
    driftspecs.(fs{i}) = dold.(fs{i});
end

% Ensure new drift spec options are present
if ~isfield(driftspecs, 'downsample_flag')
    driftspecs.downsample_flag = 0;
end
if ~isfield(driftspecs, 'points_per_frame')
    driftspecs.points_per_frame = 100;
end
if ~isfield(driftspecs, 'local_tbins_flag')
    driftspecs.local_tbins_flag = 1;
end
if ~isfield(driftspecs, 'local_tbin_width')
    driftspecs.local_tbin_width = 20;
end

driftspecs.version = 0.1;