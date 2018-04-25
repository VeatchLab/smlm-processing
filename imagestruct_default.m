function is = imagestruct_default(fname)

ds = load(fname);

nchan = numel(ds.data);
is.channels = nchan;
is.units = ds.units;
is.psize = 16;
is.imageref = default_iref(ds.data{1}, is.psize);
is.sigmablur = repmat(20, 1, nchan);
is.cmin = zeros(1, nchan);
is.cmax = is.cmin + 5;
if nchan == 1
    is.color = {'white'};
else
    is.color = {'green', 'magenta'};
end
