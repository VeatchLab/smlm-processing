function [ out ] = maskedRegionalMax( I, BW )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[xs, ys] = find(BW); % Condidates

I = I .*BW;
out = I;

[maxx, maxy] = size(I);

for i = 1:length(xs),
    x= xs(i); y = ys(i);
    val = I(x,y);
    if x > 1,
        lx = -1;
    else
        lx = 0;
    end
    if y > 1,
        ly = -1;
    else
        ly = 0;
    end
    if x<maxx,
        ux = 1;
    else
        ux = 0;
    end
    if y<maxy,
        uy = 1;
    else
        uy = 0;
    end
    
    for j = lx:ux,
        for k = ly:uy,
            if j || k,
                test = I(x+j, y+k);
                if test > val,
                    out(x,y) = 0;
                    break
                end
            end
        end
        if out(x,y) == 0,
            break
        end
    end

end

