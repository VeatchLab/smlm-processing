function [c errs] = xcors_from_imagestructs(is, r, bw_blur, psize, bw_xc)
% [C ERRS] = XCORS_FROM_IMAGESTRUCTS(IS, R, BW_BLUR, PSIZE, BW_XC)

% Copyright (C) 2023 Thomas Shaw and Sarah Veatch
% This file is part of SMLM PROCESSING 
% SMLM PROCESSING is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% SMLM PROCESSING is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with SMLM PROCESSING.  If not, see <https://www.gnu.org/licenses/>

nimage = numel(is);
nmask = sum(cellfun(@numel, {is.maskx}));
c = zeros(nmask, numel(r));
errs = zeros(nmask, numel(r));

if nargin < 5
    bw_xc = 0;
end

if nargin < 4
    psize = 15;
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

        [t1_wt, rho1] = lambdabar_tree_by_image(t1, pts1, bw_blur, psize, maskx, masky);
        [t2_wt, rho2] = lambdabar_tree_by_image(t2, pts2, bw_blur, psize, maskx, masky);

        if bw_xc
            [c(ii,:), errs(ii,:)] = xcor_tree_weights_bandwidth(t1_wt, t2_wt, r, bw_xc, maskx, masky);
        else
            [c(ii,:), errs(ii,:)] = xcor_tree_weights(t1_wt, t2_wt, r, maskx, masky);
        end
    end
end
