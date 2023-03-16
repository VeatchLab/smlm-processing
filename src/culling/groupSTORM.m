function data = groupSTORM(rawdata, window)
% DATA = GROUPSTORM(RAWDATA, WINDOW)

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
%% merge duplicates that are within a window

nframes = numel(rawdata);
sz = size(rawdata);
if sz(2) ~= nframes
    rawdata = rawdata';
    rawdata = rawdata(:);
end

lastx = []; lasty = [];
lastNframesOn = [];

data = [];
data(nframes).x = [];
data(nframes).y = [];

fields = fieldnames(rawdata(1));
fields = fields(~strcmp(fields, 'stdJ1'));

for f = 1:numel(fields),
    laststruct.(fields{f}) = [];
    data(nframes).(fields{f}) = [];
end

% Loop through frames
for i=1:nframes,
    %load in data from current frame.
    currentx = rawdata(i).x(:)';
    currenty = rawdata(i).y(:)';
    currentstruct = rawdata(i);

    NframesOn = ones(size(currentx));
    count1 = 1;
    % Check points that were in last frame
    for k=1:length(lastx),
        % see if there is a new signal within _window_ of point k from last frame
        ind = find((lastx(k)/lastNframesOn(k) - currentx).^2 + ...
                    (lasty(k)/lastNframesOn(k) - currenty ).^2 < window^2 );

        if isempty(ind),
            % if not, record the data from the last frame;
            for f = 1:numel(fields),
                field = fields{f};
                data(i-1).(field)(count1) = laststruct.(field)(k) / lastNframesOn(k);
            end

            data(i-1).NframesOn(count1) = lastNframesOn(k);
            count1 = count1+1;
        else
            % if so, add the values to record when the signal goes
            % away later.
            %TODO: note that if there are two close things, it adds both. Is that what we want?
            % (note, this is not a concern for single emitter fitting)
            for m=1:length(ind),
                currentx(ind(m)) = lastx(k) + currentx(ind(m));
                currenty(ind(m)) = lasty(k) + currenty(ind(m));
                for f = 1:numel(fields),
                    field = fields{f};
                    lvar = laststruct.(field)(k);
                    cvar = currentstruct.(field)(ind(m));
                    
                    currentstruct.(field)(ind(m)) = lvar + cvar;
                end

                NframesOn(ind(m)) = lastNframesOn(k) + 1;
            end
        end
    end

    % update last data for next pass.
    lastx = currentx;
    lasty = currenty;
    laststruct = currentstruct;

    lastNframesOn = NframesOn;
end

% record data from last frame.
for k=1:length(lastx),
    for f = 1:numel(fields),
        field = fields{f};
        data(i).(field)(k) = laststruct.(field)(k) / lastNframesOn(k);
    end

    data(i).NframesOn(k) = lastNframesOn(k);
end

if sz(2) ~= nframes
    data = reshape(data, sz(2), sz(1))';
end
