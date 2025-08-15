The crosspairs functions are a set of related algorithms which permit the efficient extraction of pairwise displacements less than a distance rmax between two datasets. They are adapted from functions contained in the R package spatstat (https://spatstat.org/), by Adrian Baddeley, Ege Rubak, and Rolf Turner. 

We implement them in C with a MATLAB interface. For our use, they typically take in x-y position data of localizations, along with associated times t.

The foundational algorithm "crosspairs" sorts each dataset with respect to its x-coordinate and loops through each point in the first dataset. Pairwise displacements in x are calculated between this point and every point in the second set until they exceed a user-inputted maximum distance rmax.

The algorithm then checks whether the total Euclidean distance between the two points is less than rmax. This method of extracting the pairs is generally far more efficient than computing the full set of pairwise displacements.

The other versions in the folder feature slight modifications to this basic template. Descriptions of each version of the crosspairs implementation follow below.

crosspairs.m. The foundational algorithm. Inputs are two sets of localizations (x1, y1, t1 and x2, y2, t2). Only pairs with dt between taumin and taumax are extracted. Outputs are dx, dy, and dt.

crosspairs_alloutputs.m Outputs dx, dy, and dt, as well as the total pairwise displacements dr and the indices i and j of the pairs within a distance of rmax.

crosspairs_indices.m Gives the indices i and j of the pairs within a distance of rmax. Slightly faster than crosspairs_alloutputs and requires less memory consumption.

crosspairs_indices_sortedt.m Gives the same outputs as crosspairs_indices, but sorting by t instead of x. This is more efficient when only a small range of tau is required.

crosspairs_rbinned.m

3D version of all these algorithms are included as well, which function similarly with the z-components of the localizations incorporated into the distance. 

Reference
1. Baddeley, A., E. Rubak, and R. Turner. 2016. Spatial point patterns: methodology and applications with R. Boca Raton; London; New York: CRC Press, Taylor & Francis Group.