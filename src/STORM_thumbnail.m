function STORM_thumbnail(fname)
% STORM_THUMBNAIL(FNAME)

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

if nargin < 1
    fname = 'final.mat';
end

d = load(fname);

is = imagestruct_default(d);

is.psize = 100;
is.imageref = default_iref(d.data{1}, is.psize);

is.cmax = ones(size(is.cmax))*8;

is.sigmablur = ones(size(is.cmax))*50;

I = imerge_from_imagestruct(is);

figure();
imshow(I);
