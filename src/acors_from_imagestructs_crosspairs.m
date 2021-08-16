function [g, gerrs] = acors_from_imagestructs_crosspairs(is, r)

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
            
            pts = [x(ind)', y(ind)'];
            
            [g{k}(iii,:), gerrs{k}(iii,:)] = xcor_crosspairs(pts, pts, r, maskx, masky);
        end
        
    end
    ii = iii; %+numel(is(i).maskx);
end