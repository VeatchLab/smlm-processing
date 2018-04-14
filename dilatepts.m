function pts = dilatepts(pts, factor)

pts = arrayfun(@(s) dilatepts_one(s, factor), pts);



function pts = dilatepts_one(pts, factor)

pts.x = pts.x * factor;
pts.y = pts.y * factor;
