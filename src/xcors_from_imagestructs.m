function [c errs l2a] = xcors_from_imagestructs(is, r)

dd = unpack_imagestructs(is);
nimage = numel(dd);

for i = 1:nimage

