function culldata = extract_culled(data, cullinds)
% CULLDATA = EXTRACT_CULLED(DATA, CULLINDS)

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

nmov = nmovies(data);
nframe = nframes(data);
nfield = numel(cullspec);

fields = fieldnames(data(1).data(1));

culldata = data;

for i = 1:nmov
    for j = 1:nframe
        inds = special_or(cullinds{i,j});
        culldata(i).data(j) = index(data(i).data(j), inds)


function out = index(data, inds)
fields = fieldnames
