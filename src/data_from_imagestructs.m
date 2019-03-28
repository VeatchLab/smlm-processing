function pts = data_from_imagestructs(is)

nimage = numel(is);
nmask = sum(cellfun(@numel, {is.maskx}));

ii = 0;
for i = 1:nimage

    if ~isempty(is(i).data)
        data = is(i).data;
    else
        data = load(is(i).data_fname);
    end

    xx = [data.data{1}(:).x];
    yy = [data.data{1}(:).y];
    zz = [data.data{1}(:).z];


    for j = 1:numel(is(i).maskx)
        ii = ii + 1;

        maskx = is(i).maskx{j};
        masky = is(i).masky{j};

        ind1 = inpolygon(xx,yy, maskx, masky);

        pts = [xx(ind1)', yy(ind1)', zz(ind1)'];
    end
end
