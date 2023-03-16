function tformdata = apply_transform(indata, tform, maxval)
% TFORMDATA = APPLY_TRANSFORM(INDATA, TFORM, MAXVAL)

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
IF NARGIN<3
    maxval = 1e5;
end

orig_state = warning; % getting original warning options for this user
% warning('off','all'); % turning warning temporarily off to avoid warmings
% about evaluating polynomial outside of bounds (this presumably happens when
% objects near the edge get shifted across the edge)

tformdata = indata;

dumped = 0; total = 0;

for i=1:size(indata,1)
    for j=1:size(indata,2)
        % call helper function, below
        [tformdata(i,j),n,d] = apply_tform_once(indata(i,j),tform,maxval);
        dumped = dumped + d; total = total + n; % update totals
    end
end

disp('Channel Registration Complete')
disp(['lost ' num2str(dumped) ' of ' num2str(total)...
    ' localizations (' num2str(100*double(dumped)/double(total), 2) '%).'])

warning(orig_state); % reset warnings


% Helper function that transforms one struct worth of data
function [out,n,lost] = apply_tform_once(indata,tform,maxval)
x = indata.x; y = indata.y;

n = numel(x);

keep = ~isnan(x+y); % check transformed data are good

% %%%%%%%%%%%%%%%%%%%%%% do the transform %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(tform)
    [y,x] = tforminv(tform,y(keep),x(keep)); % note x and y are reversed in the tform!!
end

keep = (max(x,y) < maxval); % check transformed data are good
lost = n - sum(keep);

out = structfun(@(q) q(keep), indata, 'UniformOutput', false);
out.x = x(keep); out.y = y(keep);
