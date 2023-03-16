function [Imerge, If, ir] = imerge_from_imagestruct(istruct, varargin)
% [IMERGE, IF, IR] = IMERGE_FROM_IMAGESTRUCT(ISTRUCT, VARARGIN)

% Copyright (C) 2023 Thomas Shaw and Sarah Veatch
% This file is part of SMLM PROCESSING 
% SMLM PROCESSING is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% SMLM PROCESSING is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with SMLM PROCESSING.  If not, see <https://www.gnu.org/licenses/>

if isfield(istruct, 'data') && ~isempty(istruct.data)
    ds = istruct.data;
elseif isfield(istruct, 'data_fname') && ~isempty(istruct.data_fname)
    ds = load(istruct.data_fname);
else
    error('imerge_from_imagestruct: no data or data_fname');
end

% handle varargin
if numel(varargin) > 0
    m1 = 1; f1 = 1;
    m2 = size(ds.data{1},1);
    f2 = size(ds.data{1},2);
    nf = f2;
    for i = 1:2:numel(varargin)
        switch varargin{i}
            case {'First', 'first'}
                m1 = varargin{i+1}(1); % movie1
                f1 = varargin{i+1}(2); % frame1
            case {'Last', 'last'}
                m2 = varargin{i+1}(1); % last movie
                f2 = varargin{i+1}(2); % last frame
        end
    end
    ds.data = cellfun(@(s) s', ds.data, 'UniformOutput', false);
    inds = ((m1 - 1)*nf + f1) : ((m2 - 1)*nf + f2);
    ds.data = cellfun(@(s) s(inds), ds.data, 'UniformOutput', false);
end

if numel(ds.data) ~= istruct.channels
    error('imerge_from_imagestruct: data has different number of channels from imagestruct');
end

if ~strcmp(ds.units, istruct.units)
    error('imerge_from_imagestruct: data has different units from imagestruct');
end

if isfield(istruct, 'imageref')
    ir = istruct.imageref;
else
    ir = default_iref(ds.data{1}, istruct.psize);
end

cm_size = 256;
cm = gray(cm_size);
Imerge = zeros([ir.ImageSize, 3]);
If = cell(1,3);
% Make images for each channel
for i = 1:istruct.channels
    d = ds.data{i};

    I = reconstruct(d, ir);

    % sigmas need to be in units of reconstruction pixels
    sigma = istruct.sigmablur(i)/istruct.psize; 

%     PSF = 2*pi*sigma^2*fspecial('gaussian', ceil(4*sigma), sigma);
    PSF = fspecial('gaussian', ceil(4*sigma), sigma);

    Iblur = imfilter(I, PSF, 'replicate');

    cmin = istruct.cmin(i);
    cmax = istruct.cmax(i);

    % scale to a color
    col = col2rgb(istruct.color{i});

%     If{i} = ind2rgb( 1 + uint8((cm_size - 1)*(Iblur - cmin)/(cmax - cmin)), ...
%                         cm*diag(col));
                    
    I = min(1,(Iblur - cmin)/(cmax - cmin)); % scale to [0,1]
    If{i} = cat(3, I * col(1), I * col(2), I * col(3));

    Imerge = Imerge + If{i};
end


function rgb = col2rgb(col)
if isnumeric(col) && isequal(size(col), [1 3])
    rgb=col;
else
    if ~ischar(col)
        error('col2rgb: col must be a string or a 1x3 matrix');
    end
    switch col
        case {'y', 'yellow'}
            rgb = [1 1 0];
        case {'m', 'magenta'}
            rgb = [1 0 1];
        case {'c', 'cyan'}
            rgb = [0 1 1];
        case {'r', 'red'}
            rgb = [1 0 0];
        case {'g', 'green'}
            rgb = [0 1 0];
        case {'b', 'blue'}
            rgb = [0 0 1];
        case {'w', 'white'}
            rgb = [1 1 1];
        case {'k', 'black'}
            rgb = [0 0 0];
    end
end
