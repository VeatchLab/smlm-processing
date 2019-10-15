function tracks = track_STORMdata(data, r_max, t_max, conflicts, timing)

if nargin < 4
    conflicts = 'terminate';
end

if nargin < 5
    timing = 1:numel(data);
end

blanktrack = struct('firstt', 0, 'points', [], 'lastt', 0, 'nFramesOn', 0);
tracks = repmat(blanktrack, 1, 500);
active = [];

ntracks = 0;
numeltracks = numel(tracks);

getptj = @(d,j) structfun(@(f) f(j), d, 'UniformOutput', false);

i = 0; % i is the frame index
for imov = 1:size(data,1)
    for jframe = 1:size(data,2)
        i = i + 1;
        
        t = timing(i);
        newdata = data(imov, jframe);
        
        % (I.) determine matches
        matches = false(numel(newdata.x), numel(active));
        old = false(1,numel(active));
        for k = 1:numel(active)
            dt = t - active(k).points.t(end);
            old(k) = dt > t_max;
            
            if ~old(k)
                dr2 = (active(k).points.x(end) - newdata.x).^2 + (active(k).points.y(end) - newdata.y).^2;
            
                matches(:, k) = (dr2 < r_max.^2);
            end
        end
        
        nmatch_active = sum(matches, 1);
        nmatch_new = sum(matches, 2);
        
        % (II.) resolve conflicts`
        if strcmp(conflicts, 'terminate')
                old(nmatch_active > 1) = true;
                l = find(nmatch_new > 1);
                old(any(matches(l, :),1)) = true;
                matches(l,:) = false;
                matches(:,nmatch_active > 1) = false;
        end
        
        % update active tracks that got new points
        used = zeros(size(nmatch_new));
        for j = 1:numel(newdata.x)
            k = find(matches(j, :));
            if ~isempty(k)
                used(j) = 1;
                newpt = getptj(newdata,j); %structfun(@(f) f(j), newdata, 'UniformOutput', false);
                newpt.t = t;
                active(k).points = cattracks(active(k).points, newpt);
            end
        end
        
        newtracks = active(old);
        for k = 1:numel(newtracks)
            newtracks(k).lastt = newtracks(k).points.t(end);
            newtracks(k).nFramesOn = numel(newtracks(k).points.x);
        end
        
        % move old actives to tracks
        if ~isempty(newtracks)
            ntracks_new = numel(newtracks);
            if ntracks + ntracks_new > numeltracks
                tracks(numeltracks + 500) = blanktrack;
                numeltracks = numel(tracks);
            end
            tracks(ntracks + (1:ntracks_new)) = newtracks;
            ntracks = ntracks + ntracks_new;
        end
            
        
        % remove old actives from actives
        active = active(~old);
        
        % add new points that weren't added to tracks
        k = numel(active);
        for j = 1:numel(used)
            if ~used(j)
                k = k + 1;
                
                active(k).firstt = t;
                
                newpt = getptj(newdata, j); %structfun(@(f) f(j), newdata, 'UniformOutput', false);
                newpt.t = t;
                active(k).points = newpt;
            end
        end
        
    end
end

[active.lastt] = deal(t);
for k = 1:numel(active)
    active(k).nFramesOn = numel(active(k).points.x);
end

tracks(ntracks + (1:numel(active))) = active;
tracks = tracks(1:(ntracks + numel(active)));

function out = cattracks(t1, t2)
%% note, structs t1 and t2 are presumed to have same fields
out = [];
fnms = fieldnames(t1);

for i = 1:numel(fnms)
    f = fnms{i};
    
    out.(f) = [t1.(f), t2.(f)];
end
        
