function [c, err] = xcor_crosspairs(pts1, pts2, r, maskx, masky)
    x1 = pts1(:,1);
    y1 = pts1(:,2);
    x2 = pts2(:,1);
    y2 = pts2(:,2);
    
    t1 = zeros(size(x1)); % collapse in tau
    t2 = zeros(size(x2));
    
    taumin = 0; taumax = 0; noutmax = 4e8;
    [dx, dy] = crosspairs(x1, y1, t1, x2, y2, t2, max(r), taumin, taumax, noutmax);
    dr = sqrt(dx.^2 + dy.^2);
    if numel(dx) == noutmax
        warning('Too many pairs! Consider taking a smaller number of data frames or lowering rmax.')
    end
    % get rid of localizations paired with themselves
    bad_inds = (dr == 0);
    dx = dx(~bad_inds); dy = dy(~bad_inds); dr = dr(~bad_inds); 
    
    pc = histcounts(dr, [0 r]);
    

%     redges = [0 r];
%     taumin = 0; taumax = 0; ignore_dr_0 = 1;
%     % need to deal with localizations paired with themselves!
%     tic
%     rbinned = crosspairs_rbinned(x1, y1, t1, x2, y2, t2, redges, taumin, taumax, ignore_dr_0);
%     toc
    
    n1 = numel(x1); n2 = numel(x2);
    lambda_fac = polyarea(maskx, masky)^2/(n1*n2);
    
    % compute bin geometry
    binwidth = diff([0 r]);
    rcenter = r - binwidth/2; % find bin centers
    
    edge_cor = edge_correction(maskx, masky, rcenter);
    
    % the pair correlation
    c = pc ... % counts per distance bin
        .* lambda_fac ... % (lambda1*lambda2)^(-1)
        ./ (rcenter .* binwidth * 2 * pi) ... % area of bin: 2 pi r delta_r
        ./ edge_cor; % average Ripley edge correction factor wij
    
    err = c.*sqrt(1/n1/n2 + 1./pc);
end