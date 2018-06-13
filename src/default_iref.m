function iref = default_iref(data, psize, range)


xs = [data.x];
ys = [data.y];

if nargin<3
    minx = min(xs);
    miny = min(ys);
    pwidth = ceil((max(xs) - minx)/psize);
    pheight = ceil((max(ys) - miny)/psize);
else
    minx = range(1);
    miny = range(3);
    pwidth = ceil((range(2) - minx)/psize);
    pheight = ceil((range(4) - miny)/psize);
end

width = pwidth*psize;
height = pheight*psize;

xextent = minx + [0 width];
yextent = miny + [0 height];

iref = imref2d([pheight pwidth], xextent, yextent);
