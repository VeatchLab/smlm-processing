%%

imd1 = load('imagedata1.mat', 'raw_data_filenames', 'DV_transform_specs');

% load cropdims from first timestamp
f1 = imd1.raw_data_filenames(1,:);
f1ts = [f1(1:end-5), '_timestamp.mat'];
load(f1ts, 'cropdims');

rtform = imd1.DV_transform_specs.reversetransform;

% get old/new dx
new_dx = cropdims(3) - 1
old_dx = 512 - cropdims(4)

right_inds = cropdims(3):cropdims(4);
wrong_inds = right_inds - new_dx + old_dx;

%% calculate transform images

disp('doing the transform...');
[tfx, tfy] = showtform(rtform);
disp('done with the transform...');

%%

errx = (tfx(:,right_inds) - tfx(:,wrong_inds))*160;
erry = (tfy(:,right_inds) - tfy(:,wrong_inds))*160;

err = sqrt(errx.^2 + erry.^2);

%% plots

figure(1); % x,y error images and histograms
c3 = .01*[[0:100, 99:-1:0]', [0:100, 100*ones(1,100)]' [100*ones(1,100), 10+(.9*(100:-1:0))]'];
subplot(3,2,[1 3]); % x
imagesc(errx,[-200,200]); colormap(c3);
title('X error');
axis equal off
subplot(3,2,[2 4]); % y
imagesc(erry,[-200,200]); colormap(c3); colorbar;
title('Y error');
axis equal off

% x,y error histograms
a1 = subplot(3,2,5); % x hist
colormap(a1,parula);
flt = @(I) I(:);
histogram(errx(abs(errx) < 200));
mx = mean(flt(errx),'omitnan');
legend(['mean:' newline() num2str(mx,3) ' nm']);
set(a1,'yticklabel',[]);
a2 = subplot(3,2,6); % y hist
colormap(a2,parula);
histogram(erry(abs(erry) < 200));
my = mean(flt(erry),'omitnan');
legend(['mean:' newline()  num2str(my,3) ' nm']);
set(a2,'yticklabel',[]);

% absolute error image
figure(2);
subplot(1,2,1);
imagesc(err,[0,200]); colorbar;
title('total error');
axis equal off
me = mean(flt(err),'omitnan');
a3 = subplot(1,2,2);
histogram(err(err < 200));
legend(['mean:' newline() num2str(me,3) ' nm']);
set(a3,'yticklabel',[]);
