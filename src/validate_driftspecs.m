function driftspecs = validate_driftspecs(driftspecs, version, datastruct)
% VALIDATE_DRIFTSPECS read driftspecs as correct version
%    VALIDATE_DRIFTSPECS(DRIFTSPECS, VERSION) update DRIFTSPECS structure to desired VERSION
%

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
