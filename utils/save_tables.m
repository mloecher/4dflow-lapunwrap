function save_tables(results, list_SNR, list_venc, prefix)

results = sum(results,5);

for ves = 1:4

    t = squeeze(results(ves,1,:,:))./squeeze(results(ves,3,:,:));

    figure('Position', [100, 100, 500, 500]);
    imagesc(imrotate(t,90)); 
    axis image;
    set(gca, 'FontSize', 18)
    set(gca,'XTick', 1:size(t,1), 'XTickLabel',list_SNR); 
    set(gca,'YTick', 1:size(t,2), 'YTickLabel',fliplr(list_venc)); 
    xlabel('SNR'); ylabel('venc');
    title('4D Laplacian');
    colormap('copper'); colorbar();
    filename = sprintf('table_ves%d_4D.png', ves);
    saveas(gcf, filename)
    close(gcf)


    t = squeeze(results(ves,2,:,:))./squeeze(results(ves,3,:,:));

    figure('Position', [100, 100, 500, 500]);
    imagesc(imrotate(t,90)); 
    axis image;
    set(gca, 'FontSize', 18)
    set(gca,'XTick', 1:size(t,1), 'XTickLabel',list_SNR); 
    set(gca,'YTick', 1:size(t,2), 'YTickLabel',fliplr(list_venc)); 
    xlabel('SNR'); ylabel('venc');
    title('3D Laplacian');
    colormap('copper'); colorbar();
    filename = sprintf('table_ves%d_3D.png', ves);
    saveas(gcf, filename)
    close(gcf)
end