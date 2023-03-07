function [g, gerrs] = acors_from_imagestructs(is, r)


dd = unpack_imagestructs(is, {'x','y'});
nimage = numel(dd);

for i = 1:nimage
    d = dd(i);
    [dd(i).g, ~, dd(i).N, dd(i).Norm] = spatial_acor(d.x,d.y,d.spacewin,r);
end
