function cross_validate_tforms(varargin)

if numel(varargin) < 1
    error('cross_validate_tforms: you must supply at least one transform filename');
end

% set default mask
mask.x = [0, 0, 512, 512, 0];
mask.y = [0, 256, 256, 0, 0];

tf = [];

iarg = 1;
while iarg <= numel(varargin)
    switch varargin{iarg}
        case {'mask', 'Mask'}
            iarg = iarg + 1;
            mask = varargin{iarg};
        otherwise % not a known argument type, assume it's a tform file
            dentry = dir(varargin{iarg});
            if isempty(dentry)
                error('Unknown file or named argument: %s', varargin{iarg});
            end
            
            newtf = load(fullfile(dentry.folder, dentry.name));

            if isempty(tf)
                tf = newtf;
            else
                tf = [tf, newtf];
            end
    end
    
    iarg = iarg + 1;
end

%% For now, use these tforms:
% tf(1) = load('/lipid/group/data/Thomas/2019-10-17-gabrxdisordered-contd/transformdata1.mat');
% tf(2) = load('/lipid/group/data/Thomas/2019-10-17-gabrxdisordered-contd/transformdata4.mat');
% tf(3) = load('/lipid/group/data/Thomas/2019-10-17-gabrxdisordered-contd/transformdata7.mat');

%% pull out points and tforms themselves
maskinds = @(pts) inpolygon(pts(:,1), pts(:,2), mask.x, mask.y);
for i = 1:numel(tf)
    pts1{i} = tf(i).handles_pass.used_ch1_pts;
    pts2{i} = tf(i).handles_pass.used_ch2_pts;
    
    %do masking
    inds = maskinds(pts1{i});
    pts1{i} = pts1{i}(inds,:);
    pts2{i} = pts2{i}(inds,:);
    
    rtfs(i) = tf(i).T_1_2;
end

%% 1) How does each transform transform each transforms points

for i = 1:numel(tf)
    for j = 1:numel(tf)
        [x, y] = tforminv(rtfs(j), pts2{i}(:,1), pts2{i}(:,2));
        deltas{i,j} = pts1{i} - [x,y];
        dists{i,j} = sqrt(sum(deltas{i,j}.^2,2));
    end
end

%% figure comparing these
figure;
nt = numel(tf);
for i = 1:nt
    for j = 1:nt
        iplot = i + (j - 1)*nt;
        subplot(nt, nt, iplot);
        
        scatter(deltas{i,j}(:,1), deltas{i,j}(:,2), 10, 'Marker', '.', 'MarkerEdgeAlpha', .6);
        title(sprintf('mean [%.2f, %.2f], std %.3f', ...
            mean(deltas{i,j}(:,1)), mean(deltas{i,j}(:,2)),...
            sqrt(sum(var(deltas{i,j})))));
        axis equal
    end
end

%% 2) Look at points where FRE is bad?
% 
% fields = {'LL', 'error_x'};
% 
% for i = 1:nt
%     data1 = tf(i).handles_pass.culldata.data1;
%     data2 = tf(i).handles_pass.culldata.data2;
%     
%     figure;
%     for j = 1:numel(fields)
%         
%         fdata1 = [data1.(fields{j})]';
%         fdata2 = [data2.(fields{j})]';
%         
%         subplot(numel(fields), 1, j);
%         scatter(fdata1 + fdata2, dists{i,i}, 50, dists{i,i} > 2*mean(dists{i,i}));
%         
%         colormap([0 0 0; 1 0 0]);
%         xlabel(sprintf('Sum of %s', fields{j}))
%         ylabel('registration error')
%     end
% end