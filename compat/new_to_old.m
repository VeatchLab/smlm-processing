function olddata = new_to_old(newdata)
% Turn old STORM_analyzer style struct-of-struct data
% into new style 2d struct array

[nmovies,nframes] = size(newdata);

olddata = repmat(struct('data',[]),1,nmovies);

for imov = 1:nmovies
    olddata(imov).data = newdata(imov,:);
    for iframe = 1:nframes
        n = numel(newdata(imov,iframe).x);
        olddata(imov).data(iframe).x = reshape(newdata(imov,iframe).y, n,1);
        olddata(imov).data(iframe).y = reshape(newdata(imov,iframe).x, n,1);
    end
end

