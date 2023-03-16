function pts = thresh_diag( Idisc, threshs )
%THRESH_DIAG Summary of this function goes here
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
nt = numel(threshs);
nf = size(Idisc,3);
pts = cell(nf,nt);

for i = 1:nf
    for j = 1:nt
        I = Idisc(:,:,i);
        BW  = bwmorph( I > threshs(j), 'clean');
        [x,y] = find(maskedRegionalMax(I, BW));
        pts{i,j} = [x,y];
    end
end

end

