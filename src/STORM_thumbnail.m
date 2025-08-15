function STORM_thumbnail(fname)

if nargin < 1
    fname = 'final.mat';
end

d = load(fname);

is = imagestruct_default(d);

is.psize = 100;
is.imageref = default_iref(d.data{1}, is.psize);

is.cmax = ones(size(is.cmax))*8;

is.sigmablur = ones(size(is.cmax))*50;

I = imerge_from_imagestruct(is);

figure();
imshow(I);