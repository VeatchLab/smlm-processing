function [iout, jout, status, dx, dy, dz, dr, dt] = crosspairs_indices_sortedt_3D(x1, y1, t1, z1, x2, y2, t2, z2, rmax,...
        taumin, taumax)
% efficient when only a small tau range is to be extracted

% make sure inputs are the right shape.
check_crosspairs_inputs(x1, y1, t1, z1);
check_crosspairs_inputs(x2, y2, t2, z2);
 
% Sort based on t instead of x.
[t1_s, s1] = sort(t1(:));
[t2_s, s2] = sort(t2(:));

x1_s = x1(s1);
y1_s = y1(s1);
z1_s = z1(s1);
x2_s = x2(s2);
y2_s = y2(s2);
z2_s = z2(s2);

[iout_after, jout_after, status] = Fcrosspairs_indices_sortedt_3D(x1_s, y1_s, z1_s, t1_s, x2_s, y2_s, z2_s, t2_s, rmax, taumin, taumax);
% status of 0 means okay, 1 means too many pairs

iout = s1(iout_after);
jout = s2(jout_after);
dx = x2(jout) - x1(iout);
dy = y2(jout) - y1(iout);
dz = z2(jout) - z1(iout);
dr = sqrt(dx.^2 + dy.^2 + dz.^2);
dt = t2(jout) - t1(iout);
