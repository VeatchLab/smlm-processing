function tracks = track_STORMdata_from_imagestructs(is, r_max, t_max, conflicts, which)

if nargin < 5
    which = {'x','y','t'};
end

if ~isempty(is.data)
    data = is.data;
else
    data = load(is.data_fname);
end
is.data = data;


if isfield(is, 'record_fname')
    record_fname = is.record_fname;
else
    [filepath, name, ex] = fileparts(is.data_fname);
    record_fname = [filepath '/record.mat'];
end

%load(record_fname, 'metadata');
Nmovies = size(data.data{1}, 1);%numel(metadata);
Nframes_per_movie = size(data.data{1}, 2);% metadata(1).Nframes;
%frame_time = metadata(end).frame_time;

which_w_framenumber = [which, 'framenumber'];

dd = unpack_imagestruct(is,which_w_framenumber);

% r_max = 600;
% t_max = 1;
% conflicts = 'terminate';


for i=1:numel(dd)
    disp(['working on spacial window ' num2str(i)]);
    
%     ind = spacewin_isinside(dd.x,dd.y,dd.spacewin(i));
%     
%     fields = fieldnames(dd);
%     for kk = 1:numel(fields)
%         f = fields{kk};
%         if numel(dd.(f))==numel(ind)
%             unpacked.(f) = dd.(f)(ind);
%         end
%     end
    unpacked = dd(i);
    fields = which_w_framenumber;
    timing = zeros([Nmovies, Nframes_per_movie]);
    for kk = 1:numel(fields)
        f = fields{kk};
        
        blank.(f) = [];
    end
    repacked = repmat(blank, Nmovies, Nframes_per_movie);
    
    
    for movie = 1:Nmovies
        for frame = 1:Nframes_per_movie
            ind = unpacked.framenumber == (movie-1)*Nframes_per_movie+frame;
            for kk = 1:numel(fields)
                f = fields{kk};
                if numel(unpacked.(f))==numel(ind)
                    repacked(movie,frame).(f) = [unpacked.(f)(ind)]; 
                else
                    repacked(movie,frame).(f) = unpacked.(f)(ind(1)); 
                end
                
            end
            if sum(ind)
                timing(movie, frame) = repacked(movie,frame).t(1);
            else
                timing(movie, frame) =NaN;
            end
        end
    end
    disp('... done windowing.')
    
    trackdata = track_STORMdata(repacked, r_max, t_max, conflicts);
    
    % remove stubs
    keep = [trackdata.nFramesOn]>2;
    trackdata = trackdata(keep);
    
    disp(['... done tracking. linked ' num2str(numel(trackdata)) ' trajectories.'])
    
    for t=1:numel(trackdata)
        framenumber = trackdata(t).points.framenumber;
        x = trackdata(t).points.x;
        y = trackdata(t).points.y;
        keep = find(diff(framenumber)==1);
        dr = sqrt((x(keep+1)-x(keep)).^2 + (y(keep+1)-y(keep)).^2);
        trackdata(t).drs = dr;
    end
    
    
    
    tracks(i).trackdata = trackdata;
        
end



%function repack_data(unpacked, Nmovies, frames_per_movie, frame_time)