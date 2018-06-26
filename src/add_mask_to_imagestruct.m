function is = add_mask_to_imagestruct(is)

is = is(1);

Im = imerge_from_imagestruct(is);

figure; imshow(Im, is.imageref);
hold on
for i=1:numel(is.maskx)
    plot(is.maskx{i}, is.masky{i});
end
hold off

[~, maskx, masky] = roipoly;

[maskx, masky] = poly2cw(maskx,masky);

is.maskx = [is.maskx, {maskx}];
is.masky = [is.masky, {masky}];
