function m = mask_this(I, iref, cax, m)

% This should eventually support different mask representations, I suppose
f = figure();
set(f, 'Units', 'inches', 'Position', [1 1 12 11])

a = axes('Parent', f, 'Units', 'Normalized', 'Position', [0 0 .85 1]);

imshow(I, iref, 'Parent', a, 'Border', 'Tight')
caxis(a, cax)

hold(a, 'on')
if nargin==4
    for i=1:numel(m)
        plot(m(i).x, m(i).y, 'LineWidth', 3)
    end
else
    m = [];
end

[~, mx, my] = roipoly();

[mx, my] = poly2cw(mx, my);

newm = struct('x', mx, 'y', my);

if isempty(m)
    m = newm;
else
    m(end + 1) = newm;
end

if isvalid(f)
    close(f);
end
