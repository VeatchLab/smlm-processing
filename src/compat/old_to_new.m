function newdata = old_to_new(olddata)
% Turn old STORM_analyzer style struct-of-struct data
% into new style 2d struct array

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
nmovies = numel(olddata);
nframes = numel(olddata(1).data);

% Make an empty struct with same fields as old data
emptydata = structfun(@(x) [], olddata(1).data(1), 'UniformOutput', false);
% Use it to initialize an empty nmov x nframe struct array
newdata = repmat(emptydata,nmovies,nframes);

for imov = 1:nmovies
    newdata(imov,:) = olddata(imov).data(:);
    for iframe = 1:nframes
        n = numel(newdata(imov,iframe).x);
        newdata(imov,iframe).x = reshape(newdata(imov,iframe).x, 1,n);
        newdata(imov,iframe).y = reshape(newdata(imov,iframe).y, 1,n);
    end
end
