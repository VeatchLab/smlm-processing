function [counts, counts_allr] = crosspairs_st_binned(x1, y1, t1, x2, y2, t2, ...
        rmax, nrout, taumin, taumax, ntout)

% Sort based on t
[t1, s1] = sort(t1(:));
[t2, s2] = sort(t2(:));

x1 = x1(s1);
y1 = y1(s1);
x2 = x2(s2);
y2 = y2(s2);

[counts, counts_allr] = Fcrosspairs_st_binned(x1,y1,t1, x2, y2, t2,...
                                    rmax, uint64(nrout), taumin, taumax, uint64(ntout));


                                counts = double(counts);
counts_allr = double(counts_allr);
