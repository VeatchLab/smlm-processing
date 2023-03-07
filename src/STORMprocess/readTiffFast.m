function [ Iall ] = readTiffFast( file, frames, transformfn )
%READTIFFFAST Use Tiff library to quickly read a tiff movie
%   IALL = READTIFFFAST(FILE,FRAMES,RECT) reads frame indices FRAMES from
%   tiff movie FILE, cropping to RECT.

info = imfinfo(file);

isrgb = strcmp(info(1).PhotometricInterpretation, 'RGB');
 
if nargin < 2,
 nimage = length(info);
 frames = 1:nimage;
end;

% change function to read with depending whether a crop rectangle was
% specified
if (nargin < 3 || ~isa(transformfn,'function_handle')),
    transformfn = @(I) I;
end;

tif = Tiff(file,'r');
tif.setDirectory(frames(1));
I_t = transformfn(tif.read);

Iall = zeros([size(I_t) numel(frames)]);
for i = 1:numel(frames)
    tif.setDirectory(frames(i));
    if isrgb
        Iall(:,:,:,1) = transformfn(tif.read());
    else
        Iall(:,:,i) = transformfn(tif.read());
    end
end

tif.close()

end

