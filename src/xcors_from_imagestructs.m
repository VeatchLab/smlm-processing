function [c errs l2a] = xcors_from_imagestructs(is, r, bandwidth)

nimage = numel(is);
nmask = sum(cellfun(@numel, {is.maskx}));
c = zeros(nmask, numel(r));
errs = zeros(nmask, numel(r));
l2a = zeros(1,nmask);

if nargin < 3
    bandwidth = 0;
end

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
        
        if numel(pts1) == 0 || numel(pts2) == 0
            c(ii,:) = NaN;
            errs(ii,:) = NaN;
            continue;
        end
        
        l2a(ii) = size(pts1,1)*size(pts2,1)/polyarea(maskx, masky);

        if bandwidth
            [c(ii,:), errs(ii,:)] = xcor_tree_bandwidth(t1, t2, r, bandwidth, maskx, masky);
        else
            [c(ii,:), errs(ii,:)] = xcor_tree(t1, t2, r, maskx, masky);
        end
    end
end
