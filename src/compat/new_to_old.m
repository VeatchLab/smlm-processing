function olddata = new_to_old(newdata, data_fieldname, transposex_flag,swapxy)
% Turn old STORM_analyzer style struct-of-struct data
% into new style 2d struct array

if nargin < 2
    data_fieldname = 'data';
end
if nargin < 3
    transposex_flag = true;
end
if nargin < 4
    swapxy = true;
end

[nmovies,nframes] = size(newdata);

olddata = repmat(struct(data_fieldname,[]),1,nmovies);

for imov = 1:nmovies
    olddata(imov).(data_fieldname) = newdata(imov,:);
    for iframe = 1:nframes
        n = numel(newdata(imov,iframe).x);
        olddata(imov).(data_fieldname)(iframe).tI = newdata(imov, iframe).I;
        olddata(imov).(data_fieldname)(iframe).AR = ones(size(newdata(imov, iframe).I));
        if transposex_flag
            olddata(imov).(data_fieldname)(iframe).x = reshape(newdata(imov,iframe).y, n,1);
            olddata(imov).(data_fieldname)(iframe).y = reshape(newdata(imov,iframe).x, n,1);
        end
        if swapxy
            x = olddata(imov).(data_fieldname)(iframe).x;
            olddata(imov).(data_fieldname)(iframe).x = ...
                olddata(imov).(data_fieldname)(iframe).y;
            olddata(imov).(data_fieldname)(iframe).y = x;
        end
    end
end

