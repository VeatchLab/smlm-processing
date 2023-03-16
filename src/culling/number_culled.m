function [nleft, fleft, foverlap] = number_culled(cullinds, fields, movinds)
% [NLEFT, FLEFT, FOVERLAP] = NUMBER_CULLED(CULLINDS, FIELDS, MOVINDS)

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

if nargin < 3
    movinds = 1:size(cullinds,1);
end

if isa(fields, 'char')
    fields = {fields};
end

inds = [cullinds(movinds,:).(fields{1})];
orred = [cullinds(movinds,:).(fields{1})];
for i = 2:numel(fields)
    f = fields{i};
    
    inds = inds & [cullinds(movinds,:).(f)];
    orred = orred | [cullinds(movinds,:).(f)];
end

ntot = numel(inds);
nleft = sum(inds);
fleft = nleft/ntot;

nminimal = sum(orred);
noverlap = nminimal - nleft;
foverlap = noverlap/(ntot - nleft);
