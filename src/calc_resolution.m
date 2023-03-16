function [res, info] = calc_resolution(data, options);%bin, n, how, maxr)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

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

if nargin<2
    options = resolution_default('nm');
end
maxr = options.maxr;
how = options.how;
n = options.niter;
bin = options.binsize;

data = data';

r = bin:bin:maxr;
rc = r-bin/2;

x1 = [data(:).x];
y1 = [data(:).y];

minx = min(x1);
maxx = max(x1);
miny = min(y1);
maxy = max(y1);

box = [minx, maxx, miny, maxy];
[maskx, masky] = poly2cw([minx maxx maxx minx minx] ,[miny miny maxy maxy miny]);
ind1 = inpolygon(x1,y1, maskx, masky);
pts1 = [x1(ind1)', y1(ind1)'];
t1 = tree_from_points(box, pts1, 1000);
c1 = xcor_tree(t1, t1, r, maskx, masky);

maxframe = size(data, 1)*size(data, 2);

c2 = 0;

parfor kk=1:n
    switch how
        case 'sequential'
            ind_sub = kk:n:maxframe;
        case 'random'
            ind_sub = randperm(maxframe, floor(maxframe/n));
    end
    x2 = [data(ind_sub).x];
    y2 = [data(ind_sub).y];
    ind2 = inpolygon(x2,y2, maskx, masky);
    pts2 = [x2(ind2)', y2(ind2)'];
    t2 = tree_from_points(box, pts2, 1000);
    c2 = c2+xcor_tree(t2, t2, r, maskx, masky)/n;
end



c = c1-c2;

F = fit(rc(2:end)', c(2:end)', 'a1*exp(-x^2/2/c1^2)', 'startpoint', [1 bin]);

%plot(F, rc(2:end)', c(2:end)')

res = F.c1/sqrt(2);

info.c = c;
info.c1 = c1;
info.c2 = c2;
info.F = F;
info.rc = rc;
info.r = r;
info.how = how;

end

