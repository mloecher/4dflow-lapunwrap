function res = compare_results(n_ref, n_u4, n_u3, masks)
%% COMPARE_RESULTS Counts the number of voxels correctly unwrapped
%
% Args:
%     n_ref: true unwrap counts
%     n_u4:  unwrap counts via 4D Laplacian
%     n_u3:  unwrap counts via 3D Laplacian
%     masks: vessel masks
% 
% Returns:
%     res: number of wrapped voxels that were NOT unwrapped
%          (num vessels x 3 matrix)

res = zeros(4,3);

cutoff = 12; % Dont check in the excitation region

for i = 1:4
   MASK = repmat(masks(:,:,i), [1 1 size(n_ref,3)-cutoff*2 size(n_ref,4)]);
   
   diff_u4 = abs(n_ref(:,:,cutoff:end-cutoff-1,:)-n_u4(:,:,cutoff:end-cutoff-1,:));
   diff_u4 = diff_u4.*MASK;
   
   diff_u3 = abs(n_ref(:,:,cutoff:end-cutoff-1,:)-n_u3(:,:,cutoff:end-cutoff-1,:));
   diff_u3 = diff_u3.*MASK;
   
   diff_full = abs(n_ref(:,:,cutoff:end-cutoff-1,:));
   diff_full = diff_full.*MASK;
   
   res(i,1) = sum(diff_u4(:));
   res(i,2) = sum(diff_u3(:));
   res(i,3) = sum(diff_full(:));
end
