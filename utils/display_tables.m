function display_tables(results, list_SNR, list_venc, ves)

if (nargin < 4), ves=2; end

results = sum(results,5);

t = squeeze(results(ves,1,:,:))./squeeze(results(ves,3,:,:));

figure('Position', [100, 100, 1000, 500]);
subplot(1,2,1);
imagesc(imrotate(t,90), [0 1]); 
axis image;
set(gca,'XTick', 1:size(t,1), 'XTickLabel',list_SNR); 
set(gca,'YTick', 1:size(t,2), 'YTickLabel',fliplr(list_venc)); 
xlabel('SNR'); ylabel('venc');
title('4D Laplacian');
colormap('copper'); colorbar();

t = squeeze(results(ves,2,:,:))./squeeze(results(ves,3,:,:));

subplot(1,2,2);
imagesc(imrotate(t,90), [0 1]);
axis image;
set(gca,'XTick', 1:size(t,1), 'XTickLabel',list_SNR); 
set(gca,'YTick', 1:size(t,2), 'YTickLabel',fliplr(list_venc)); 
xlabel('SNR'); ylabel('venc');
title('3D Laplacian');
colormap('copper'); colorbar();