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
if isfield(datastruct.data{1}(1), 'z')
    driftspecs = drift_default(datastruct, 'spline');
else
    driftspecs = drift_default(datastruct, 'gaussianPSF');
end
fs = fieldnames(dold);
for i = 1:numel(fs)
    driftspecs.(fs{i}) = dold.(fs{i});
end

driftspecs.version = 0.1;