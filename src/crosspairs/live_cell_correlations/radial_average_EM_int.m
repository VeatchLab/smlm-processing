function [r, vals, er] = radial_average_EM_int(I, rmax, int, flag)

if nargin<2, rmax = 100; end
if nargin<3, flag=0; end

%rmax = 200;
%I = Gsmall;
%flag = 1;

%flag = 1;
%I = G;

l = rmax;
L = size(I, 1);

center1 = ceil((size(I, 1)+1)/2);
center2 = ceil((size(I, 2)+1)/2);
% 
% center1 = ceil((size(I, 1))/2);
% center2 = ceil((size(I, 2))/2);

range1 = center1-rmax:center1+rmax;
range2 = center2-rmax:center2+rmax;

xvals = ones(1, 2*rmax+1)'*(-rmax:rmax);
yvals = (-rmax:rmax)'*ones(1, 2*rmax+1);
zvals = I(range1, range2);

[theta,r,v] = cart2pol(xvals,yvals, zvals);

Ar = reshape(r,1, (2*rmax+1)^2);
Avals = reshape(v,1, (2*rmax+1)^2);


[rr,ind] = sort(Ar);
vv = Avals(ind);

r = 0:floor(max(rr));
r = 0:int:floor(max(rr));
[n bin] = histc(rr, r);

for j = 1:(rmax/int)+1;%length(r),
    m = bin==j;
    n2 = sum(m);
    if n2==0, vals(j)=0; er(j)=0; 
    else
        vals(j) = sum(m.*vv)/n2;
        er(j) = sqrt(sum(m.*(vv-vals(j)).^2))/n2;
    end
end

r = 0:int:rmax;

if flag,
    plotpts = (1:rmax/int+1);
    errorbar(r(plotpts), vals(plotpts), er(plotpts))
    hold off
end


