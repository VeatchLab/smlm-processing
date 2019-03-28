function [SPspecs, inds] = fix_movieorder(SPspecs, namestr)
    % This function is for changing the order of movies in
    % an SPspecs to reflect the numbers in the filenames
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
