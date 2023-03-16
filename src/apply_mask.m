function data = apply_mask(data, maskx, masky)
% DATA = APPLY_MASK(DATA, MASKX, MASKY)

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

for i = 1:numel(data)
    xs = data(i).x;
    ys = data(i).y;

    inds = inpolygon(xs, ys, maskx, masky);

    data(i) = structfun(@(x) x(inds), data(i), 'UniformOutput', false);
end
