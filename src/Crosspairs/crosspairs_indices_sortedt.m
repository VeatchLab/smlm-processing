function [iout, jout, status, dx, dy, dr, dt] = crosspairs_indices_sortedt(x1, y1, t1, x2, y2, t2, rmax, mintau, maxtau)

% Put the data in the right shape. Data inputs must be vectors.
x1 = reshape(x1', 1, numel(x1));
y1 = reshape(y1', 1, numel(y1));
t1 = reshape(t1', 1, numel(t1));
x2 = reshape(x2', 1, numel(x2));
y2 = reshape(y2', 1, numel(y2));
t2 = reshape(t2', 1, numel(t2));

% Sort based on t instead of x.
[t1_s, s1] = sort(t1(:));
t1_s = t1_s';
[t2_s, s2] = sort(t2(:));
t2_s = t2_s';

x1_s = x1(s1);
y1_s = y1(s1);
x2_s = x2(s2);
y2_s = y2(s2);

[iout_after, jout_after, status] = Fcrosspairs_indices_sortedt(x1_s, y1_s, t1_s, x2_s, y2_s, t2_s, rmax, mintau, maxtau);
% status of 0 means okay, 1 means too many pairs

iout = s1(iout_after);
jout = s2(jout_after);
dx = x2(jout) - x1(iout);
dy = y2(jout) - y1(iout);
dr = sqrt(dx.^2 + dy.^2);
dt = t2(jout) - t1(iout);
end