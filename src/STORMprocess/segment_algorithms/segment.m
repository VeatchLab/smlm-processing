function bginfo = segment(Iall, specs)
nframe = size(Iall,3);

Imed = median(Iall,3);
Imean = mean(Iall,3);

passes = 1;

switch specs.bg_type
    case 'median'
        Ibg = Imed;
    case 'mean'
        Ibg = Imean;
    case 'selective'
        Ibg = Imed;
        passes = 2;
    case 'none'
        Ibg = zeros(size(Iall(:,:,1)));
    otherwise
        error(['no such bg_type: ', specs.bg_type]);
end

for pass = 1:passes
    Idisc = zeros(size(Iall));
    ce = cell(1,nframe);
    parfor i = 1:nframe
        Idisc(:,:,i) = filter_frame(Iall(:,:,i) - Ibg);  %make a new one for spline 
        BW  = bwmorph( Idisc(:,:,i) > specs.thresh, 'clean');
        [y,x,val] = find(maskedRegionalMax(Idisc(:,:,i), BW));
        ce{i} = [x,y,val];
    end
    if sum(Ibg(:))==0 % don't bother because there is no background.
        Isel = Ibg;
        Nsel = Ibg;
        Psel = Ibg;
        break
    end
    [Isel, Nsel, Psel] = selective_mean(Iall, ce, specs.r_centroid);
    if Ibg == Isel % then further passes won't help
        break
    end
    Ibg = Isel;
end

switch specs.fit_method
    case {'gaussianPSF','scmos'}

        % Remove neighbors
        ce2 = remove_neighbors(ce, specs.r_neighbor);
        
        % Remove points too close to edge
        ce = remove_edges(ce,size(Imed,2),size(Imed,1),specs.r_centroid);
        ce2 = remove_edges(ce2,size(Imed,2),size(Imed,1),specs.r_centroid);
      
    case 'spline'
        ce = remove_edges(ce,size(Imed,2),size(Imed,1),specs.r_centroid);
        ce2 = group_pairs(ce, specs.r_mingroup, specs.r_maxgroup);
        ce2 = remove_neighbors(ce2, specs.r_neighbor);
end

separatepts = @(pts) cellfun(@(x) x(:,[1,2]), pts, 'UniformOutput', false);
% transpose is because this will later go into data
separatevals = @(pts) cellfun(@(x) x(:,3)', pts, 'UniformOutput', false);
        
bginfo.Imean = Imean;
bginfo.Imed = Imed;
bginfo.Isel = Isel;
bginfo.Nsel = Nsel;
bginfo.Psel = Psel;
bginfo.threshold = specs.thresh;
bginfo.ptspre = separatepts(ce);
bginfo.pts = separatepts(ce2);
bginfo.discvals = separatevals(ce2);

function coords = remove_edges(coords,width,height,dL)
    nframes = numel(coords);

    % Get coords that aren't at edge
    for i =1:nframes
        c = coords{i};
        if(numel(c))
            inds = ((c(:,1) > dL) & (c(:,1) < width - dL) & ...
                (c(:,2) > dL) & (c(:,2) < height - dL));
            coords{i} = c(inds,:);
        end
    end

function coords = remove_neighbors(coords, dr)
nframes = numel(coords);

for i = 1:nframes
    c = coords{i};
    if numel(c) > 0 % sum(c(:))>0
        x = c(:,1); y = c(:,2);
        n = size(c,1);
        mask = ones(1,n);
        for j = 1:(n-1)
            for k = (j+1):n
                if (((x(j) - x(k))^2 + (y(j) - y(k))^2) < dr^2)
                    mask(j) = 0;
                    mask(k) = 0;
                end
            end
        end
        coords{i} = c(logical(mask),:);
    end
end

function coords = group_pairs(coords, r1, r2)
nframes = numel(coords);
for i = 1:nframes
    c = coords{i};
    x = c(:,1); y = c(:,2);
    n = size(c,1);
    count = 1;
    %first find pairs that match criteria
    cn = zeros(0,3);
    for j = 1:(n-1)
        for k = (j+1):n
            rsq = ((x(j) - x(k))^2 + (y(j) - y(k))^2);
            if (rsq > r1^2 && rsq < r2^2)
                cn(count, :) = (c(j, :)+c(k, :))/2;
                %inds_in_pair(count, :) = [j k];
                count = count+1;
            end
        end
    end
    if ~isempty(cn)
        coords{i} = [floor(cn(:, 1:2)) cn(:, 3)]; 
    else
        coords{i} = zeros(0,3);
    end
end
