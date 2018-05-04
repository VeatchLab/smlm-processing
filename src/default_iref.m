function iref = default_iref(data, psize)

xs = [data.x];
ys = [data.y];

minx = min(xs);
miny = min(ys);
pwidth = ceil((max(xs) - minx)/psize);
pheight = ceil((max(ys) - miny)/psize);

width = pwidth*psize;
height = pheight*psize;

xextent = minx + [0 width];
yextent = miny + [0 height];

iref = imref2d([pheight pwidth], xextent, yextent);
