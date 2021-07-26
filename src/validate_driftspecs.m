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
if driftspecs.version == 0
    if isfield(datastruct.data{1}(1), 'z')
        d = drift_default(datastruct, 'spline');
    else    
        d = drift_default(datastruct, 'gaussianPSF');
    end
end

driftspecs.version = 0.1;
