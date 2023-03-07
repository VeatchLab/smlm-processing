function add_Tgeo_to_tform(fname)

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
