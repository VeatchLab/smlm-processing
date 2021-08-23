function [g, gerrs] = acors_from_imagestructs(is, r)

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

    for k = 1:numel(data.data)
        
        x = [data.data{k}(:).x];
        y = [data.data{k}(:).y];
        
        iii = ii;
        for j = 1:numel(is(i).maskx)
            
            iii = iii + 1;
            
            maskx = is(i).maskx{j};
            masky = is(i).masky{j};
            
            ind = inpolygon(x,y, maskx, masky);
            %ind2 = inpolygon(x2,y2, maskx, masky);
            
            pts = [x(ind)', y(ind)'];
            %pts2 = [x2(ind2)', y2(ind2)'];
            
            box = [min(maskx), max(maskx), min(masky), max(masky)];
            t = tree_from_points(box, pts, r(end)/2);
            %t2 = tree_from_points(box, pts2, 1000);
            
            [g{k}(iii,:), gerrs{k}(iii,:)] = xcor_tree(t, t, r, maskx, masky);
            %[g2(ii,:), g2errs(ii,:)] = xcor_tree(t2, t2, r, maskx, masky);
        end
        
    end
    ii = iii; %+numel(is(i).maskx);
end
