function adata = imagedata_to_newdata(imdata_fname)

if isnumeric(imdata_fname)
    switch imdata_fname
        case 1
            imdata_fname = 'imagedata1.mat';
        case 2
            imdata_fname = 'imagedata2.mat';
        otherwise
            error('invalid input');
    end
end

load(imdata_fname, 'alignment_data');

% adata.x = [alignment_data.alldata.x];
% adata.y = [alignment_data.alldata.y];
% adata.I = [alignment_data.alldata.I];
for i = 1:numel(alignment_data.alldata_track)
    adata(i, :) = arrayfun(@(s) structfun(@(f) f(:)', s, 'UniformOutput', false),...
                        alignment_data.alldata_track(i).rawdata);
end

if isfield(adata, 'Ninds')
    adata = rmfield(adata, 'Ninds');
end

% adata = arrayfun(@(s) structfun(@(f) f(:)', s, 'UniformOutput', false),...
%     alignment_data.alldata);
