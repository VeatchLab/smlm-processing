function olddata = new_to_old(newdata, data_fieldname, transposex_flag)
% Turn old STORM_analyzer style struct-of-struct data
% into new style 2d struct array

if nargin < 2
    data_fieldname = 'data';
end
if nargin < 3
    transposex_flag = true;
end

[nmovies,nframes] = size(newdata);

olddata = repmat(struct(data_fieldname,[]),1,nmovies);

for imov = 1:nmovies
    olddata(imov).data = newdata(imov,:);
    for iframe = 1:nframes
        n = numel(newdata(imov,iframe).x);
        if transposex_flag
            olddata(imov).(data_fieldname)(iframe).x = reshape(newdata(imov,iframe).y, n,1);
            olddata(imov).(data_fieldname)(iframe).y = reshape(newdata(imov,iframe).x, n,1);
        end
    end
end

