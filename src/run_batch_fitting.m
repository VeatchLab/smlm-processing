function run_batch_fitting(nchannels, varargin)
if exist('./record.mat', 'file')
    warning('Record already exists in this dir, aborting cleanly');
    return;
end
record = SP_record_default(nchannels, varargin{:});

[data, ~, metadata] = STORMprocess(record.SPspecs);

fits.data = data;
fits.date = datetime;
fits.produced_by = 'STORMprocess';
fits.units = 'px';

save(record.fits_fname, 'fits');

record.metadata = metadata;
save record.mat -struct record
