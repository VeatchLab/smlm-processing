function [nleft, fleft, foverlap] = number_culled(cullinds, fields, movinds)

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
