function data = apply_mask(data, maskx, masky)

for i = 1:numel(data)
    xs = data(i).x;
    ys = data(i).y;

    inds = inpolygon(xs, ys, maskx, masky);

    data(i).x = xs(inds);
    data(i).y = ys(inds);
end
