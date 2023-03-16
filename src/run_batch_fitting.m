function run_batch_fitting(nchannels, varargin)
% RUN_BATCH_FITTING(NCHANNELS, VARARGIN)

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
IF EXIST('./RECORD.MAT', 'FILE')
    warning('Record already exists in this dir, aborting cleanly');
    return;
end
record = SP_record_default(nchannels, 'gaussianPSF', varargin{:});
save record.mat -struct record % in case something breaks later, save this right away.

% Fitting step
[data, ~, metadata] = STORMprocess(record.SPspecs);

record.metadata = metadata;

fits.data = data;
fits.date = datetime;
fits.produced_by = 'STORMprocess';
fits.units = 'px';

if ~isempty(record.fits_fname)
    save(record.fits_fname, '-struct', 'fits');
end

cont = true; % set this false if some failure
% Transform step
if cont & ~isempty(record.dv_transform_fname)
    try
        transformed = transform_block(fits, record);

        if ~isempty(record.transformed_fname)
            save(record.transformed_fname, '-struct', 'transformed');
        end
    catch ME
        warning('An error ocurred in the transform step:\n%s', ME.message);
        cont = false;
    end
else
    cont = false;
end

if cont
    % do to different datasets depending on number of channels
    if isempty(record.tform_channel)
        startdata = fits;
    else
        startdata = transformed;
    end

    % apply the dilation to each channel
    dilated = dilate_block(startdata, record, 'nm');

    if ~isempty(record.dilated_fname)
        save(record.dilated_fname, '-struct', 'dilated');
    end
end

save record.mat -struct record
