function adata = get_adata_from_imagedata(imdata_fname)

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

adata.x = [alignment_data.alldata.x];
adata.y = [alignment_data.alldata.y];
adata.I = [alignment_data.alldata.I];