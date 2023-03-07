function bginfo = segment_for_Isel(Iall, thresh, r)
nframe = size(Iall,3);

Imed = median(Iall,3);
Imean = mean(Iall,3);

nft = 0;
ce = cell(1,nframe);
parfor i = 1:nframe
    Idisc = filter_frame(Iall(:,:,i) - Imed);
    BW  = bwmorph( Idisc > thresh, 'clean');
    [y,x] = find(maskedRegionalMax(Idisc, BW));
    ce{i} = [x,y];
    nft = nft + numel(x);
end
[Isel, Nsel, Psel] = selective_mean(Iall, ce, r);

bginfo.Imed = Imed;
bginfo.Imean = Imean;
bginfo.Isel = Isel;
bginfo.Nsel = Nsel;
bginfo.Psel = Psel;
bginfo.threshold = thresh;
bginfo.ptspre = ce;
bginfo.nft = nft;
