function pts = thresh_diag( Idisc, threshs )
%THRESH_DIAG Summary of this function goes here
%   Detailed explanation goes here
nt = numel(threshs);
nf = size(Idisc,3);
pts = cell(nf,nt);

for i = 1:nf
    for j = 1:nt
        I = Idisc(:,:,i);
        BW  = bwmorph( I > threshs(j), 'clean');
        [x,y] = find(maskedRegionalMax(I, BW));
        pts{i,j} = [x,y];
    end
end

end

