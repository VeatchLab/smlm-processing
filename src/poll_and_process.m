function poll_and_process(varargin)
olddirs = {};
here = cd;
while true
    tmp = dir();
    dirs = {tmp.name};

    newdirs = setdiff(dirs, olddirs);
    olddirs = dirs;

    if isempty(newdirs)
        disp('No new dirs to process');
        pause(600);
    end
    for i = 1:numel(newdirs)
        if ~isempty(regexp(newdirs{i}, '[Cc]ell', 'once'))
            disp(['fitting to do in ' newdirs{i}]);
            cd(newdirs{i});
            files = dir();
            while true
                pause(60);
                if isequal(files, dir())
                    break;
                else
                    files = dir();
                    disp('new files in last minute -- waiting to see if there are more');
                end
            end
            run_batch_fitting(2, varargin{:});
        elseif ~isempty(regexp(newdirs{i}, 'beads', 'once'))
            disp(['fiducials to do in ' newdirs{i}]);
            cd(newdirs{i});
            files = dir();
            while true
                pause(60);
                if isequal(files, dir())
                    break;
                else
                    files = dir();
                    disp('new files in last minute -- waiting to see if there are more');
                end
            end
            do_fidfind();
        end
        cd(here);
    end
end
