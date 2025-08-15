function pts = dilatepts(pts, factor, zcalib)

if nargin==3
    pts = arrayfun(@(s) dilatepts_one_wz(s, factor, zcalib), pts);
else
    pts = arrayfun(@(s) dilatepts_one(s, factor), pts);
end


function pts = dilatepts_one(pts, factor)

pts.x = pts.x * factor;
pts.y = pts.y * factor;

function pts = dilatepts_one_wz(pts, factor, zcalib)

pts.x = pts.x * factor;
pts.y = pts.y * factor;

%zo = length(zcalib)/2;
%dz = 1e3*mean(diff(zcalib));
pts.z = spline(1:length(zcalib), zcalib, double(pts.z));

%pts.z = (pts.z-zo)*dz;% +zo;
