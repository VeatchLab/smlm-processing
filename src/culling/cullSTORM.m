function [data, cullinds] = cullSTORM(rawdata, cullspec)
% [DATA, CULLINDS] = CULLSTORM(RAWDATA, CULLSPEC)

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

nmov = nmovies(rawdata);
nframe = nframes(rawdata);
nfield = numel(cullspec);

cullinds = repmat(struct([]), nmov, nframe);
cullindsall = repmat(struct('inds', []), nmov, nframe);

data = rawdata;

for k = 1:nfield % loop over fields to cull by
    f = cullspec(k).field; 
    t = cullspec(k).culltype;
    l = cullspec(k).min; % lower bound and ...
    u = cullspec(k).max; % upper bound of cull

    % if culltype is none, then no need to include it in cullinds
    if strcmp(t, 'none')
        continue;
    end

    % culling by quantile over all movies, calculate the quantiles
    if strcmp(t, 'quantile')
        [l, u] = getmoviequantiles(rawdata, 1:nmov, f, l, u);
    elseif strcmp(t, 'sds')
        [fieldmean, fieldsd] = getmoviesds(rawdata, 1:nmov, f);
        l = fieldmean + fieldsd*l;
        u = fieldmean + fieldsd*u;
    end

    for i = 1:nmov % loop over movies

        % culling by quantile over each movie, calculate the quantiles
        if strcmp(t, 'permoviequantile')
            l = cullspec(k).min; % lower bound and ...
            u = cullspec(k).max; % upper bound of cull
            [l, u] = getmoviequantiles(rawdata,i,  f, l, u);
        elseif strcmp(t, 'permoviesds')
            l = cullspec(k).min; % lower bound and ...
            u = cullspec(k).max; % upper bound of cull
            [fieldmean, fieldsd] = getmoviesds(rawdata, i, f);
            l = fieldmean + fieldsd*l;
            u = fieldmean + fieldsd*u;
        end

        % loop over frames of movie
        for j = 1:nframe
            framedata = getframe(rawdata, i, j);
            if ~isfield(framedata, f)
                break;
            end

            % Construct cullinds for this (movie,frame,field) combination
%            if strcmp(t, 'none')
%                cullinds(i,j).(f) = true(1, numel(framedata.(f)));
%            elseif strcmp(t, 'absolute') || strcmp(t, 'quantile') || ...
%                    strcmp(t, 'permoviequantile') || strcmp(t, 'sds') || ...
%                    strcmp(t, 'permoviesds');
                cullinds(i,j).(f) = cull_abso(framedata.(f), l, u);
%            else
%                warning('Unknown cull type, skipping...');
%                break;
%            end

            % AND the new indices with any previous ones
            if numel(cullindsall(i,j).inds)
                cullindsall(i,j).inds = cullindsall(i,j).inds & cullinds(i,j).(f);
            else % In case this is the first field
                cullindsall(i,j).inds = cullinds(i,j).(f);
            end
        end
    end
end

% Construct data, if requested
fields = fieldnames(data);
for i = 1:nmov
    for j = 1:nframe
        inds = cullindsall(i,j).inds; % inds for this frame
        for k = 1:numel(fields)
            f = fields{k};
            old = data(i,j).(f);
            data(i,j).(f) = old(inds);
        end
    end
end


% Little helper functions
function n = nmovies(data)
%n = numel(data);
n = size(data,1);

function n = nframes(data)
%n = numel(data(1).data);
n = size(data,2);

function framedata = getframe(data, imov, iframe)
%framedata = data(imov).data(iframe);
framedata = data(imov,iframe);

function [ql, qh] = getmoviequantiles(data, movie, field, l, u)
data = data(movie,:);
data = flattendata(data);
if isfield(data, field)
    data = data.(field);
    ql = quantile(data, l);
    qh = quantile(data, u);
else % field does not exist
    ql = 0; qh = 0;
end

function [fieldmean, fieldsd] = getmoviesds(data, movie, field, l, u)
data = data(movie,:);
data = flattendata(data);
if isfield(data, field)
    data = data.(field);
    fieldmean = mean(data);
    fieldsd = std(data);
else % field does not exist
    fieldsd = 0; fieldmean = 0;
end

function ind = cull_abso(pre, min, max)
ind = pre < max & pre > min;

function flat = flattendata(movdata)
data = [movdata(:)];
fs = fieldnames(data);
for i =  1:numel(fs)
    flat.(fs{i}) = [data(:).(fs{i})];
end
