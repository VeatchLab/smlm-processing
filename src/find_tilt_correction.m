function [coeffs, fitinfo] = find_tilt_correction(datastruct, regions)


Is = imagestruct_default(datastruct);



Is.cmax=[.1];

for ii = 1:regions
    Is = add_mask_to_imagestruct(Is);
    close(gcf)
end


pts = data_from_imagestructs(Is);
fitinfo = fit([pts(:, 1), pts(:, 2)],pts(:, 3), 'poly11');
coeffs = coeffvalues(fitinfo);
plot(fitinfo, [pts(:, 1), pts(:, 2)],pts(:, 3))

% 
% 
% xx = [datain{1}(:).x];
% yy = [datain{1}(:).y];
% zz = [datain{1}(:).z];
% 
% zcorrected = zeros(1,size(zz(:),1));
% for jj = 1:size(zz(:),1)
%     zsubtract = coeffs(1) + coeffs(2)*xx(jj) + coeffs(3)*yy(jj);
%     zcorrected(jj) = zz(jj) + zsubtract;
%     
% end


function pts = data_from_imagestructs(is)

nimage = numel(is);
nmask = sum(cellfun(@numel, {is.maskx}));

ii = 0;
pts = [];
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

        pts = [pts; xx(ind1)', yy(ind1)', zz(ind1)'];
    end
end



