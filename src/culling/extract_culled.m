function culldata = extract_culled(data, cullinds)

nmov = nmovies(data);
nframe = nframes(data);
nfield = numel(cullspec);

fields = fieldnames(data(1).data(1));

culldata = data;

for i = 1:nmov
    for j = 1:nframe
        inds = special_or(cullinds{i,j});
        culldata(i).data(j) = index(data(i).data(j), inds)


function out = index(data, inds)
fields = fieldnames
