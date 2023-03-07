function fnames = glob_fnames(glob)
% Get filenames matching the given glob (UNIX glob syntax: *,?,[], etc)
fs = dir(glob);
dates = [fs.datenum];
n = numel(dates);

if n == 0
    fnames = {};
    return;
end
% names = strcat({fs.folder},repmat({'/'},1,n),{fs.name});
names = strcat({fs.name});

% Sort by date ... should usually work
[~, sortinds] = sort(dates);
fnames = names(sortinds);
