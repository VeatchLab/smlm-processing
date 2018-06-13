function iref = default_iref(data, psize)

if isnumeric(data)
    if size(data) == [1 4] % user gave a window
        dtype = 'window';
    elseif size(data,2) == 2
        dtype = 'points';
        xs = data(:,1)';
        ys = data(:,2)';
    end
else
    dtype = 'points';
    xs = [data.x];
    ys = [data.y];
end

switch dtype
    case 'window'
        range = data;

        minx = range(1);
        miny = range(3);
        pwidth = ceil((range(2) - minx)/psize);
        pheight = ceil((range(4) - miny)/psize);
    case 'points'
        minx = min(xs);
        miny = min(ys);
        pwidth = ceil((max(xs) - minx)/psize);
        pheight = ceil((max(ys) - miny)/psize);
end

width = pwidth*psize;
height = pheight*psize;

xextent = minx + [0 width];
yextent = miny + [0 height];

iref = imref2d([pheight pwidth], xextent, yextent);
