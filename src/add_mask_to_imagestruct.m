function is = add_mask_to_imagestruct(is)
% IS = ADD_MASK_TO_IMAGESTRUCT(IS)

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

is = is(1);

Im = imerge_from_imagestruct(is);

h = figure; imshow(Im, is.imageref);
hold on
for i=1:numel(is.maskx)
    plot(is.maskx{i}, is.masky{i});
end
hold off

[~, maskx, masky] = roipoly;

[maskx, masky] = poly2cw(maskx,masky);

is.maskx = [is.maskx, {maskx}];
is.masky = [is.masky, {masky}];

if isvalid(h)
    close(h);
end
