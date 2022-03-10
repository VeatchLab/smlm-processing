function newdata = old_to_new_flipxy(olddata)
% Turn old STORM_analyzer style struct-of-struct data
% into new style 2d struct array

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

        % switch x & y in data
        tmp.xy = newdata(imov,iframe).x;
        newdata(imov,iframe).x = newdata(imov,iframe).y;
        newdata(imov,iframe).y = tmp.xy;
                       
        % switch dx & dy 
        tmp.dxdy = newdata(imov,iframe).dx;
        newdata(imov,iframe).dx = newdata(imov,iframe).dy;
        newdata(imov,iframe).dy = tmp.dxdy;
                
        % switch errorx & errory
        tmp.error = newdata(imov,iframe).errorx;
        newdata(imov,iframe).errorx = newdata(imov,iframe).errory;
        newdata(imov,iframe).errory = tmp.error;
        
        clear tmp
    end
end