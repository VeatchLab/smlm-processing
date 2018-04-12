function I = reconstruct(xs, ys, ireg)
% use ireg

left = ireg.XWorldLimits(1);
right = ireg.XWorldLimits(2);
top = ireg.YWorldLimits(1);
bottom = ireg.YWorldLimits(2);
pwidth = ireg.PixelExtentInWorldX;
pheight = ireg.PixelExtentInWorldY;

xedges = left:pwidth:right;
yedges = top:pheight:bottom;

I = histcounts2(ys, xs, yedges, xedges);
