function px_shift = correct_dx_in_record(record_fname, backup_suffix)
% PX_SHIFT = CORRECT_DX_IN_RECORD(RECORD_FNAME, BACKUP_SUFFIX)

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
PX_SHIFT = 0;

if nargin < 1
    record_fname = 'record.mat';
end
if nargin < 2
    backup_suffix = '_wrongdx';
end

record = load(record_fname);

% check that dx is wrong
mdata = record.metadata(1);
if isfield(mdata, 'version') && mdata.version >= 1
    fprintf('This record already has the dx fix\n');
    return;
end

for i = 1:numel(record.metadata)
    record.metadata(i).version = 1;
    record.metadata(i).rot90 = 1;
end
cropdims = mdata.cropdims;

% note, using dx since that's the convention from STORMdata, but this shift
% actually gets applied to the y coordinate
wrong_dx = cropdims(3) - 1;
right_dx = 512 - cropdims(4);

cspecs = record.SPspecs(1).camera_specs;
px_shift = right_dx - wrong_dx;
nm_shift = px_shift * 1e3 * cspecs.pixel_size / cspecs.magnification;

if wrong_dx == right_dx
    fprintf('wrong and right dx match in this case: %d\n', right_dx);
    save(record_fname, '-struct', 'record');
    return;
end

% fix fits
fits = load(record.fits_fname);
fits.data = cellfun(@(x) translatepts(x, 0, px_shift), fits.data, ...
    'UniformOutput', false);

fbase = regexp(record.fits_fname, '(.*)\.mat|(.*)', 'tokens');
new_fname = [fbase{1}{1} backup_suffix '.mat'];

movefile(record.fits_fname, new_fname);
save(record.fits_fname, '-struct', 'fits');

if isempty(record.dv_transform_fname) && ~isempty(record.tform_channel)
    save(record_fname, '-struct', 'record');
    return
end

% do transform
transformed = transform_block(fits, record);

if ~isempty(record.transformed_fname)
    fbase = regexp(record.transformed_fname, '(.*)\.mat|(.*)', 'tokens');
    new_fname = [fbase{1}{1} backup_suffix '.mat'];
    
    movefile(record.transformed_fname, new_fname);
    save(record.transformed_fname, '-struct', 'transformed');
end

% do dilation
dilated = dilate_block(transformed, record);

if ~isempty(record.dilated_fname)
    fbase = regexp(record.dilated_fname, '(.*)\.mat|(.*)', 'tokens');
    new_fname = [fbase{1}{1} backup_suffix '.mat'];
    
    movefile(record.dilated_fname, new_fname);
    save(record.dilated_fname, '-struct', 'dilated');
end

% do culling
[culled, cullinds] = cull_block(dilated, record);
record.cullinds = cullinds;

if ~isempty(record.culled_fname)
    fbase = regexp(record.culled_fname, '(.*)\.mat|(.*)', 'tokens');
    new_fname = [fbase{1}{1} backup_suffix '.mat'];
    
    movefile(record.culled_fname, new_fname);
    save(record.culled_fname, '-struct', 'culled');
end

% apply or compute drift
if record.tform_channel == record.driftspecs.channel % should recompute drift
    [final, drift_info] = compute_drift_block(culled, record);
    
    record.drift_info = drift_info;
else % can reapply old drift
    final = apply_drift_block(culled, record);
end

if ~isempty(record.final_fname)
    fbase = regexp(record.final_fname, '(.*)\.mat|(.*)', 'tokens');
    new_fname = [fbase{1}{1} backup_suffix '.mat'];
    
    movefile(record.final_fname, new_fname);
    save(record.final_fname, '-struct', 'final');
end

save(record_fname, '-struct', 'record');
