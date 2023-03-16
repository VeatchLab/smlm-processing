function pts = dilatepts(pts, factor, zcalib)
% PTS = DILATEPTS(PTS, FACTOR, ZCALIB)

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

if nargin==3
    pts = arrayfun(@(s) dilatepts_one_wz(s, factor, zcalib), pts);
else
    pts = arrayfun(@(s) dilatepts_one(s, factor), pts);
end


function pts = dilatepts_one(pts, factor)

pts.x = pts.x * factor;
pts.y = pts.y * factor;

function pts = dilatepts_one_wz(pts, factor, zcalib)

pts.x = pts.x * factor;
pts.y = pts.y * factor;

%zo = length(zcalib)/2;
%dz = 1e3*mean(diff(zcalib));
pts.z = spline(1:length(zcalib), zcalib, double(pts.z));

%pts.z = (pts.z-zo)*dz;% +zo;
