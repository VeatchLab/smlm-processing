function res_specs = validate_res_specs(res_specs, version)
% VALIDATE_DRIFTSPECS read res_specs as correct version
%    VALIDATE_DRIFTSPECS(DRIFTSPECS, VERSION) update DRIFTSPECS structure to desired VERSION
%
if ~isfield(res_specs, 'version')
    res_specs.version = 0;
end

while res_specs.version < version
    res_specs = update_res_specs(res_specs);
end

if res_specs.version ~= version
    error('Could not update res_specs to this version. Is res_specs version newer than requested?')
end


function res_specs = update_res_specs(res_specs)
% UPDATE_res_specs update the res_specs struct from its current version to the next one
fprintf('input res_specs was version %f. updating now\n', res_specs.version);
% retain settings from previous version of res_specs
rold = res_specs;
res_specs = resolution_default('nm');
fs = fieldnames(rold);
for i = 1:numel(fs)
    res_specs.(fs{i}) = rold.(fs{i});
end

res_specs.version = 0.1;