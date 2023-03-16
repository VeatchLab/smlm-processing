function bginfo = segment_for_Isel(Iall, thresh, r)
% BGINFO = SEGMENT_FOR_ISEL(IALL, THRESH, R)

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
nframe = size(Iall,3);

Imed = median(Iall,3);
Imean = mean(Iall,3);

nft = 0;
ce = cell(1,nframe);
parfor i = 1:nframe
    Idisc = filter_frame(Iall(:,:,i) - Imed);
    BW  = bwmorph( Idisc > thresh, 'clean');
    [y,x] = find(maskedRegionalMax(Idisc, BW));
    ce{i} = [x,y];
    nft = nft + numel(x);
end
[Isel, Nsel, Psel] = selective_mean(Iall, ce, r);

bginfo.Imed = Imed;
bginfo.Imean = Imean;
bginfo.Isel = Isel;
bginfo.Nsel = Nsel;
bginfo.Psel = Psel;
bginfo.threshold = thresh;
bginfo.ptspre = ce;
bginfo.nft = nft;
