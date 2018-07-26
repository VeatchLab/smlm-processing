function [g1 g2 g1errs g2errs] = acors_from_imagestructs(is, r)

nimage = numel(is);
nmask = sum(cellfun(@numel, {is.maskx}));
g1 = zeros(nmask, numel(r));
g2 = zeros(nmask, numel(r));
g1errs = zeros(nmask, numel(r));
g2errs = zeros(nmask, numel(r));

ii = 0;
for i = 1:nimage

    if ~isempty(is(i).data)
        data = is(i).data;
    else
        data = load(is(i).data_fname);
    end

    x1 = [data.data{1}(:).x];
    y1 = [data.data{1}(:).y];
    x2 = [data.data{2}(:).x];
    y2 = [data.data{2}(:).y];


    for j = 1:numel(is(i).maskx)
        ii = ii + 1;

        maskx = is(i).maskx{j};
        masky = is(i).masky{j};

        ind1 = inpolygon(x1,y1, maskx, masky);
        ind2 = inpolygon(x2,y2, maskx, masky);

        pts1 = [x1(ind1)', y1(ind1)'];
        pts2 = [x2(ind2)', y2(ind2)'];

        box = [min(maskx), max(maskx), min(masky), max(masky)];
        t1 = tree_from_points(box, pts1, 1000);
        t2 = tree_from_points(box, pts2, 1000);

        [g1(ii,:), g1errs(ii,:)] = xcor_tree(t1, t1, r, maskx, masky);
        [g2(ii,:), g2errs(ii,:)] = xcor_tree(t2, t2, r, maskx, masky);
    end
end
