function transformed = transform_block(data, record)
% TRANSFORMED = TRANSFORM_BLOCK(DATA, RECORD)

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

transformed = data;

if record.tform_channel % only transform if specified

    transf_fname = record.dv_transform_fname;
    if exist(transf_fname, 'file')
        % the transform structures only have reverse transforms,
        % so we need T_1_2 to transform 2->1
        tf_mat = load(transf_fname, 'T_1_2', 'Version', 'dims1', 'dims2');
        tf = tf_mat.T_1_2;
    else
        error('dualview transform file not specified or does not exist');
    end

    % Check consistency of various things
    % Might want to check Version for something
    % Check Dims
    if isfield(tf_mat, 'dims1')
        msg = 'channel dims for transform are different from those used for fitting';
        switch record.tform_channel
            case 1
                if ~isequal(tf_mat.dims2, record.SPspecs(1).channel_dims)
                    error(msg);
                end
            case 2
                if ~isequal(tf_mat.dims1, record.SPspecs(1).channel_dims) || ...
                        ~isequal(tf_mat.dims2, record.SPspecs(2).channel_dims)
                    error(msg);
                end
            otherwise
                error('I don''t know how to transform that channel yet');
        end
    else
        warning(['Channel dims not specified in transform file. Can''t check for',...
                    'consistency with fitting specs. Proceed at your own risk']);
    end

    [tfdata] = apply_transform(data.data{record.tform_channel}, tf);

    transformed.data{record.tform_channel} = tfdata;

    transformed.date = datetime;
    transformed.produced_by = 'apply_transform';
    transformed.units = 'px';
end
