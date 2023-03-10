classdef FitQueue < handle
properties
  specs, fitfun
  psfs, others
  nqueued
  chunks % which fits go with which movie/frame
  jobs, njobs % parfevalFuture instances
  data % output data
end
methods
  % Constructor. Take care of given specs.
  function fq = FitQueue(specs)
    fq.specs = specs;
    %TODO: able to add options via varargin
    fprintf('fit_method is %s\n', specs.fit_method);
    nothers = 1;
    switch specs.fit_method
        case 'gaussianPSF'
            fq.fitfun = @(psf,bg) fitpsf_gpumle_ptx(psf,bg,specs);
        case 'spline'
            cal=load(specs.spline_calibration_fname);
            coeff=cal.cspline.coeff;
            fq.fitfun = @(psf,bg) fitpsf_gpuspline(psf, bg, fittype, specs, coeff);
        case 'scmos'
            fq.fitfun = @(psf,bg,vars) fitpsf_gpuscmos(psf, bg, specs, vars);
            nothers = 2;
    end            
    fq.jobs = cell(1,5);
    fq.chunks = fq.newchunk();
    fq.njobs = 0;
    npx = 2*specs.r_centroid + 1;
    fq.psfs = zeros(npx, npx, specs.nmax, 'single');
    fq.others = cell(1,nothers);
    for i = 1:nothers
        fq.others{i} = zeros(npx, npx, specs.nmax, 'single');
    end
    fq.nqueued = 0;

  end

  % add psfs to the queue, and dispatch parallel jobs if appropriate
  function add(fq,psfstack,others,coords,movinds)
    nmax = fq.specs.nmax; nmin = nmax * .5;

    % check for valid movinds. 3rd column is number of fits. Should sum to
    % length of psfstack.
    ntot = size(psfstack,3);
    if ntot ~= sum(movinds(:,3))
        error('FitQueue.add: invalid movinds. ntot: %d, sum(movinds), %d', ...
                    ntot, sum(movinds(:,3)));
    end

    for j = 1:size(movinds,1) % number of (movie,frame) pairs
        nnew = movinds(j,3); % number of fits for this pair
        while (nnew > 0)
            ichunk = fq.njobs + 1; % chunk index for current queue
            nqueued = fq.nqueued; %#ok<*PROPLC>
            if (nnew + nqueued > nmax)
                % dispatch nmax psfs
                ndif = nmax - nqueued;
                fq.psfs(:,:,nqueued + (1:ndif)) = single(psfstack(:,:,1:ndif));
                for k = 1:numel(fq.others)
                    fq.others{k}(:,:,nqueued + (1:ndif)) = single(others{k}(:,:,1:ndif));
                end
                fq.chunks(ichunk).coords(nqueued + (1:ndif),:) = coords(1:ndif,:);
                fq.chunks(ichunk).movinds = vertcat(fq.chunks(ichunk).movinds, movinds(j,:));
                fq.chunks(ichunk).movinds(end,3) = ndif;
                movinds(j,3) = movinds(j,3) - ndif;
                fq.nqueued = nmax;

                % forget queued psfs
                psfstack = psfstack(:,:,(ndif+1):end);
                for k = 1:numel(fq.others)
                    others{k} = others{k}(:,:,(ndif+1):end);
                end
                coords = coords((ndif + 1):end,:);
                nnew = nnew - ndif; %size(psfstack,3);

                % dispatch
                fq.dispatch();
            else
                fq.psfs(:,:,nqueued + (1:nnew)) = single(psfstack(:,:,1:nnew));
                for k = 1:numel(fq.others)
                    fq.others{k}(:,:,nqueued + (1:nnew)) = single(others{k}(:,:,1:nnew));
                end
                fq.chunks(ichunk).coords(nqueued + (1:nnew),:) = coords(1:nnew,:);
                fq.chunks(ichunk).movinds = vertcat(fq.chunks(ichunk).movinds, movinds(j,:));
                nqueued = nqueued + nnew;
                fq.nqueued = nqueued;

                % forget queued psfs
                psfstack = psfstack(:,:,(nnew+1):end);
                for k = 1:numel(fq.others)
                    others{k} = others{k}(:,:,(nnew+1):end);
                end
                coords = coords((nnew + 1):end,:);

                if (nqueued == nmax) % Just in case we got to exactly nmax
                    fq.dispatch();
                end

                % Done queueing for this movind row
                break;
            end
        end
    end

    if (fq.nqueued > nmin) % dispatch whatever's there
        fq.dispatch();
    end

  end

  function c = newchunk(fq)
    nmax = fq.specs.nmax;

    c = struct('coords', zeros(nmax,2), 'n', 0, 'movinds', zeros(0,3), 'data', []);
  end

  % dispatch a fitting job, from whatever is queued.
  function dispatch(fq)
    if(fq.nqueued == 0)
        return
    end

    njobs = fq.njobs; %#ok<*PROP>
%     if (njobs == numel(fq.jobs)) % extend jobs cell if necessary
%         fq.jobs(njobs + (1:5)) = cell(1,5);
%     end

    inds = 1:fq.nqueued;
    others = cellfun(@(stk) stk(:,:,inds), fq.others, 'UniformOutput', false);
    newdata = fq.fitfun(fq.psfs(:,:,inds), others{:});
    
    j = njobs + 1;
            emptydata = structfun(@(x) [], newdata, 'UniformOutput', false);
            emptydata.x = []; emptydata.y = [];
            if (numel(fq.data) == 0)
                fq.data = emptydata;
            end
            fq.chunks(j).data = newdata;
            fields = fieldnames(newdata);

            % make data in canonical form for fitting data, e.g.:
            % data(imov, iframe).error(iemitter)
            movinds = fq.chunks(j).movinds;

            % extend fq.data if necessary
            imovmax = max(movinds(:,1));
            iframemax = max(movinds(:,2));
            if (imovmax > size(fq.data,1) || iframemax > size(fq.data,2))
                fq.data(imovmax,iframemax) = emptydata;
            end

            ndone = 0; % how many have already been placed
            index = @(mat, inds) mat(inds);
            for k = 1:size(movinds,1)
                imov = movinds(k,1);
                iframe = movinds(k,2);
                num = movinds(k,3); % number of fits that belong to (imov, iframe)

                for l = 1:numel(fields)
                    f = fields{l};
                    nd = index(newdata.(f),ndone + (1:num));
                    nd = double(nd); % because TFORMINV expects doubles
                    fq.data(imov,iframe).(f) = [fq.data(imov,iframe).(f), nd];
                end

                xoffset = fq.chunks(j).coords(ndone + (1:num),1)';
                yoffset = fq.chunks(j).coords(ndone + (1:num),2)';
                newx = newdata.xroi(ndone + (1:num)) + xoffset;
                newy = newdata.yroi(ndone + (1:num)) + yoffset;
                newx = double(newx); newy = double(newy);

                fq.data(imov,iframe).x = [fq.data(imov,iframe).x, newx];
                fq.data(imov,iframe).y = [fq.data(imov,iframe).y, newy];

                ndone = ndone + num;
            end
    fq.chunks(njobs + 1).n = fq.nqueued;
    fq.njobs = njobs + 1;

    if (njobs + 1 >= numel(fq.chunks)) % extend chunks cell
        fq.chunks(njobs + 2) = fq.newchunk();
    end

    fq.nqueued = 0;
  end

  % collect results from finished fitting jobs
  function collect(fq)

%     for j = 1:fq.njobs
%         job = fq.jobs{j};
%         if (isa(job, 'parallel.FevalFuture') && strcmp(job.State, 'finished'))
%             newdata = job.fetchOutputs();

            % Check if text output contains errors
%             out_text = job.Diary;
%             if ~isempty(regexp(out_text, 'You should clear this function', 'ONCE'))
%                 fprintf('Error from fitting call. Text output:\n%s\n', out_text);
%                 error('Fitting');
%             end
            

            % Clean up job
%             delete(job);
%             fq.jobs{j} = [];
%         end
%     end
  end

  % wait for remaining fitting jobs to finish
  function waitall(fq)
    fq.dispatch(); % Dispatch stragglers
    for j = 1:fq.njobs
        job = fq.jobs{j};
        if isa(job, 'parallel.FevalFuture')
            job.wait();
        end
    end
    fq.collect();
  end

  % return data
  function data = extract(fq)
    fq.waitall();
    data = fq.data;
  end

end
end
