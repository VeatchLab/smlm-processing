olddirs = {};
here = cd;
while true
    tmp = dir();
    dirs = {tmp.name};

    newdirs = setdiff(dirs, olddirs);
    olddirs = dirs;

    if isempty(newdirs)
        disp('No new dirs to process');
        pause(60);
    end
    for i = 1:numel(newdirs)
        if ~isempty(regexp(newdirs{i}, 'cell'));
            disp(['fitting to do in ' newdirs{i}]);
            cd(newdirs{i});
            run_batch_fitting(2);
        elseif ~isempty(regexp(newdirs{i}, 'beads'))
            disp(['fiducials to do in ' newdirs{i}]);
            cd(newdirs{i});
            do_fidfind();
        end
        cd(here);
    end
end
