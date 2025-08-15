function rbinned = crosspairs_rbinned(x1, y1, t1, x2, y2, t2, redges,...
        taumin, taumax, ignore_dr_0)

% make sure inputs are the right shape.
check_crosspairs_inputs(x1, y1, t1);
check_crosspairs_inputs(x2, y2, t2);
 
% Sort based on x
[x1, s1] = sort(x1(:));
x1 = x1';
[x2, s2] = sort(x2(:));
x2 = x2';

y1 = y1(s1);
t1 = t1(s1);
y2 = y2(s2);
t2 = t2(s2);

rbinned = Fcrosspairs_rbinned(x1, y1, t1, x2, y2, t2,...
                                    redges, taumin, taumax, ignore_dr_0);
