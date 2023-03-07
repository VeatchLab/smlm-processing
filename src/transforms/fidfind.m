function [left_data,right_data,rough_tform,left_dims,right_dims,missed_left,missed_right, diagnostics] = fidfind(files, varargin)

show_missed = true;

left_inds = [1,256,1,512];
right_inds = [257,512,1,512];

if numel(varargin) > 0
    field_ind = find(strcmp('channel_dims', varargin));
    if ~isempty(field_ind)
        left_inds = varargin{field_ind(1)+1}{1};
        right_inds = varargin{field_ind(1)+1}{2};
    end
end


if nargin<1 || isempty(files)
    % See if we can guess which files to use
    filelist = dir('*.tif'); % all the tiffs, never mind order
    filelist = [filelist dir('*.Tif')];
    filelist = [filelist dir('*.tiff')];
    files = {filelist.name};
end

diagnostics.files = files;

if (numel(files) == 0)
    error('No files, aborting');
end

%if nargin < 2
    % make a rough transform
    I = double(imread(files{1}));
    Il = I(left_inds(3):left_inds(4), left_inds(1):left_inds(2));
    Ir = I(right_inds(3):right_inds(4), right_inds(1):right_inds(2));
    [o,m] = imregconfig('multimodal');
    o.InitialRadius = 1e-3;
    o.MaximumIterations = 300;
    lastwarn(''); % clear last warning
    % Make the rigid transform from right to left
    rough_tform = imregtform(Ir, Il, 'similarity', o,m);
    [m, mid] = lastwarn(); % see if there was a warning;
    if strcmp(mid, 'images:regmex:registrationOutBoundsTermination')
        fprintf('Last warning was: %s\n', m);
        answer = questdlg('Automatic registration failed for some reason, Set rough_tform manually?',...
            'manual register?', 'OK', 'Cancel', 'OK');
        if ~strcmp(answer, 'OK')
            error('fidfind: No rough_tform, aborting...');
        end
        
        offset = mean(max(Il(:)), max(Ir(:)));
        f = figure(1);
        a = imshowpair(Il + offset, Ir + offset);
        II = get(a, 'CData');
        set(a, 'CData', ((II/3)*2 + 64));
        title('Choose a magenta bead, and corresponding green bead');
        [x, y] = ginput(2);
        close(f);
        
        dx = x(2) - x(1);
        dy = y(2) - y(1);
        rough_tform = affine2d([1 0 0; 0 1 0; dx dy 1]);
    end
%end

sp_specs = default_specs_dualview(varargin{:});
[sp_specs.movie_fnames] = deal(files);
[sp_specs.bg_type] = deal('none');
[sp_specs.thresh] = deal(2);
[sp_specs.mle_iters] = deal(80);
[sp_specs.r_centroid] = deal(4);
[sp_specs.r_neighbor] = deal(7);

[left_dims, right_dims] = deal(sp_specs(:).channel_dims);

d = STORMprocess(sp_specs);

left_raw = d{1};
right_raw = d{2};

% Initialize empty structs for output data
% make_empty_structs = @(x) structfun(@(y) [], x, 'UniformOutput',false);
empty_struct = struct('fp',[],'x',[],'y',[], ...
    'wx',[],'wy',[],'amp',[],'offset',[],'theta',[],'tI',[],'error_x',[], ...
    'error_y',[],'error_wx',[],'error_wy',[],'error_amp',[],'error_offset',[],...
    'error_theta',[],'dist',[], 'LL', []);

left_data = empty_struct; % make_empty_structs(left_raw(1));
right_data = left_data;
missed_left = left_data;
missed_right = left_data;

nimg = numel(files);

pcount = 1;
mcountl = 1;
mcountr = 1;


for i = 1:nimg
    dl = left_raw(i);
    dr = right_raw(i);
    
    lx = dl.x; ly = dl.y; %coordinates in left frame
    rx = dr.x; ry = dr.y; %coordinates in right frame
    
    if (isempty(rx))
        continue
    end
    
    % right frame coordinates, transformed to match left frame
    [rx_transf, ry_transf] = transformPointsForward(rough_tform,rx,ry);
    
    % for each point on left, find closest point on right
    done_on_right = false(1,numel(rx));
    done_on_left = false(1,numel(lx));
    
    
    to_tfm_format = @(d,j) struct('fp',[],'x',d.x(j),'y',d.y(j),...
                'wx',d.widthxx(j),'wy',d.widthxx(j),'amp',d.I(j),...
                'offset',d.bg(j),'theta',0,'tI',d.I(j),'error_x',d.errorx(j),...
                'error_y',d.errory(j),'error_wx',d.errorsigma(j),...
                'error_wy',d.errorsigma(j),'error_amp',d.errorI(j),...
                'error_offset',d.errorbg(j),'error_theta',0,'dist',m,...
                'LL', d.LL(j));
        
    for j = 1:numel(lx)
        x1 = lx(j); y1 = ly(j);
        delta_r = [(x1 - rx_transf)',(y1 - ry_transf)'];
        dx_to_dist2 = @(dx) dx(:,1).^2 + dx(:,2).^2;
        delta_r2 = dx_to_dist2(delta_r);
        m = sqrt(min(delta_r2));
        k = find(delta_r2 == min(delta_r2));
        
        if (m < 3 && ~done_on_right(k)) % two pixels away. Too generous? not enough?
        
            left_data(pcount) = to_tfm_format(dl,j);
            right_data(pcount) = to_tfm_format(dr,k);
            diagnostics.imnum(pcount) = i;
            
            done_on_left(j) = true;
            done_on_right(k)  = true;
            
            pcount = pcount + 1;
        elseif m < 3 && done_on_right(k)
            % The closest find has already been assigned somewhere
            warning('this point has already been assigned!');
        end
    end
    
    % save points that were missed, for diagnostics
    for j = 1:numel(lx)
        if ~done_on_left(j)
            missed_left(mcountl) = to_tfm_format(dl,j);
            mcountl = mcountl + 1;
        end
    end
    for j = 1:numel(rx)
        if ~done_on_right(j)
            missed_right(mcountr) = to_tfm_format(dr,j);
            mcountr = mcountr + 1;
            if show_missed
                hold off;
                plot([dl.x], [dl.y],'.','MarkerSize', 20); hold on;
                plot(rx_transf, ry_transf,'.','MarkerSize',10);
                plot(rx_transf(j), ry_transf(j),'ro','MarkerSize', 20);
                axis equal off;
                pause(.1);
            end
        end
    end
end

n_found = pcount - 1;
n_missed_left = mcountl - 1;
n_missed_right = mcountr - 1;
n_tot_left = n_missed_left + n_found;
n_tot_right = n_missed_right + n_found;
pct_left = n_missed_left / n_tot_left * 100;
pct_right = n_missed_right / n_tot_right * 100;

fprintf('Missed localizations: %d of %d (%.0f%%) in the left frame, and %d of %d (%.0f%%) on the right\n',...
    n_missed_left, n_tot_left, pct_left, n_missed_right, n_tot_right, pct_right);
