function [Imerge, If, ir] = imerge_from_imagestruct_viewport(istruct, viewport, varargin)
% IMERGE_FROM_IMAGESTRUCT_VIEWPORT Render only the visible portion of the reconstruction
%   [IMERGE, IF, IR] = IMERGE_FROM_IMAGESTRUCT_VIEWPORT(ISTRUCT, VIEWPORT, ...)
%   renders only the portion of the reconstruction that is visible in the
%   current viewport to improve performance when zoomed in.
%
%   Inputs:
%       istruct - image structure with data and parameters
%       viewport - [xmin, xmax, ymin, ymax] viewport coordinates
%       varargin - optional arguments for frame range
%
%   Outputs:
%       Imerge - merged image for the viewport
%       If - individual channel images
%       ir - image reference for the viewport

if isfield(istruct, 'data') && ~isempty(istruct.data)
    ds = istruct.data;
elseif isfield(istruct, 'data_fname') && ~isempty(istruct.data_fname)
    ds = load(istruct.data_fname);
else
    error('imerge_from_imagestruct_viewport: no data or data_fname');
end

% handle varargin for frame range
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
    error('imerge_from_imagestruct_viewport: data has different number of channels from imagestruct');
end

if ~strcmp(ds.units, istruct.units)
    error('imerge_from_imagestruct_viewport: data has different units from imagestruct');
end

% Create a viewport-specific image reference
if isfield(istruct, 'imageref')
    ir_original = istruct.imageref;
else
    ir_original = default_iref(ds.data{1}, istruct.psize);
end

% Calculate viewport bounds
xmin = viewport(1);
xmax = viewport(2);
ymin = viewport(3);
ymax = viewport(4);

% Create a new image reference for the viewport
viewport_width = xmax - xmin;
viewport_height = ymax - ymin;

% Calculate pixel size based on viewport
pixel_size = istruct.psize;

% Check if pixel size is too small (less than 1 nm) and adjust if necessary
if pixel_size < 1
    pixel_size = max(1, pixel_size);
    warning('Pixel size adjusted to minimum of 1 nm for viewport rendering');
end

% Calculate image size with minimum pixel size constraint
max_image_size = 2048; % Maximum image size to prevent memory issues
image_width = ceil(viewport_width / pixel_size);
image_height = ceil(viewport_height / pixel_size);

% If image is too large, increase pixel size
if image_width > max_image_size || image_height > max_image_size
    scale_factor = max(image_width / max_image_size, image_height / max_image_size);
    pixel_size = pixel_size * scale_factor;
    image_width = ceil(viewport_width / pixel_size);
    image_height = ceil(viewport_height / pixel_size);
    warning('Pixel size increased to %g nm to prevent memory issues', pixel_size);
end

ir = imref2d([image_height, image_width]);
ir.XWorldLimits = [xmin, xmax];
ir.YWorldLimits = [ymin, ymax];

cm_size = 256;
cm = gray(cm_size);
Imerge = zeros([ir.ImageSize, 3]);
If = cell(1,3);

% Make images for each channel
for i = 1:istruct.channels
    d = ds.data{i};
    
    % Filter data to only include points in the viewport
    x = [d.x];
    y = [d.y];
    in_viewport = x >= xmin & x <= xmax & y >= ymin & y <= ymax;
    
    if sum(in_viewport) > 0
        % Create filtered data structure
        d_filtered = struct('x', x(in_viewport), 'y', y(in_viewport));
        
        % Reconstruct only the viewport portion
        I = reconstruct_viewport(d_filtered, ir);
    else
        % No points in viewport, create empty image
        I = zeros(ir.ImageSize);
    end

    % sigmas need to be in units of reconstruction pixels
    sigma = istruct.sigmablur(i)/istruct.psize; 

    % Apply Gaussian blur
    PSF = fspecial('gaussian', ceil(4*sigma), sigma);
    Iblur = imfilter(I, PSF, 'replicate');

    cmin = istruct.cmin(i);
    cmax = istruct.cmax(i);

    % scale to a color
    col = col2rgb(istruct.color{i});
                    
    I = min(1,(Iblur - cmin)/(cmax - cmin)); % scale to [0,1]
    If{i} = cat(3, I * col(1), I * col(2), I * col(3));

    Imerge = Imerge + If{i};
end

function I = reconstruct_viewport(data, ir)
% RECONSTRUCT_VIEWPORT Reconstruct image for a specific viewport
%   I = RECONSTRUCT_VIEWPORT(DATA, IR) reconstructs an image for the
%   specified viewport using the image reference IR.

left = ir.XWorldLimits(1);
right = ir.XWorldLimits(2);
top = ir.YWorldLimits(1);
bottom = ir.YWorldLimits(2);
pwidth = ir.PixelExtentInWorldX;
pheight = ir.PixelExtentInWorldY;

xedges = left:pwidth:right;
yedges = top:pheight:bottom;

if ~isempty(data) && isfield(data, 'x') && ~isempty(data.x)
    xs = [data.x]; 
    ys = [data.y];
    I = histcounts2(ys, xs, yedges, xedges);
else
    I = zeros(length(yedges)-1, length(xedges)-1);
end 