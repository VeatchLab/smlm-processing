function run_batch_fitting(nchannels, varargin)
if exist('./record.mat', 'file')
    warning('Record already exists in this dir, aborting cleanly');
    return;
end
record = SP_record_default(nchannels, varargin{:});
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
        transformed = trasform_block(fits, record);

        if ~isempty(record.transformed_fname)
            save(record.transformed_fname, '-struct', 'transformed');
        end
    catch ME
        warning('An error ocurred in the transform step:\n%s', ME.message);
        cont = false;
    end
end

if cont
    cspecs = record.SPspecs.camera_specs;
    dilatefac = cspecs.pixel_size / cspecs.magnification * 1e3; %to nm

    % do to different datasets depending on number of channels
    if isempty(record.tform_channel)
        startdata = fits;
    else
        startdata = transformed;
    end

    % apply the dilation to each channel
    dilateddata = cellfun(@(d) dilatepts(d, dilatefac), startdata.data,...
                    'UniformOutput', false);

    dilated.data = dilateddata;
    dilated.date = datetime;
    dilated.units = 'nm';
    dilated.produced_by = 'dilatepts';

    if ~isempty(record.dilated_fname)
        save(record.dilated_fname, '-struct', 'transformed');
    end
end

save record.mat -struct record
