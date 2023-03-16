function [SPspecs, inds] = fix_movieorder(SPspecs, namestr)
    % This function is for changing the order of movies in
    % an SPspecs to reflect the numbers in the filenames


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
    namestr = 'movie';
end
movie_fnames = SPspecs.movie_fnames;

for i=1:numel(movie_fnames)
    endind = strfind(movie_fnames{i}, '.tif')-1;
    number(i) = str2double(movie_fnames{i}(1+length(namestr):endind));
end

[val, inds] = sort(number);

for i=1:numel(movie_fnames)
    new{i} = movie_fnames{inds(i)};
end

SPspecs.movie_fnames = new;
