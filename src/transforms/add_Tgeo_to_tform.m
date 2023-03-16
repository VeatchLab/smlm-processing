function add_Tgeo_to_tform(fname)
% ADD_TGEO_TO_TFORM(FNAME)

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

tf = load(fname);

if ~isfield(tf, 'T_geo')
    % the fliplr is a x for y swap, so we don't have to do transposes
    % before imwarp
    ch1_pts = fliplr(tf.handles_pass.used_ch1_pts);
    ch2_pts = fliplr(tf.handles_pass.used_ch2_pts);
    
    fprintf('Refitting transform using fitgeotrans\n')
    
    newtform = fitgeotrans(ch2_pts, ch1_pts, 'lwm', 24);
    tf.T_geo = newtform;
    
    fprintf('Saving...\n')
    
    save(fname, '-struct', 'tf');
end
