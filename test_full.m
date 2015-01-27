%% TEST_FULL.m Test unwrapping method for various SNR and and venc values
%
%  NOTE:  This is the code used to generate the data in the paper, and can
%  take a very long time to run.  If you just want to see a single demo,
%  look at test_single.m

%%
clear all
clc

addpath('utils');
addpath('unwrap')

%% Settings

n_trials = 1;    % Run multiple trials (account for randomness, =20 in paper) 
list_SNR = 1:10; 
list_venc = .1:.1:1.0;

%%
results = zeros(4, 3, length(list_SNR), length(list_venc), n_trials);
[VEL, MAG, MASKS] = gen_phantom([512 512]);

for nt = 1:n_trials
for i_SNR = 1:length(list_SNR)
for i_venc = 1:length(list_venc)
    SNR = list_SNR(i_SNR);
    venc = list_venc(i_venc);
    fprintf('SNR: %f    venc: %f\n', SNR, venc)

    [IM, Vref, masks] = make_phantom_3d(VEL, MAG, MASKS, [256 256], 1, 256, venc, SNR);

    phi = angle(IM);
    
    % True unwrapping
    n_true = zeros(size(phi),'int8');
    for i = 1:size(phi,3)
       n_true(:,:,i,:) = round((Vref - squeeze(phi(:,:,i,:)))./(2*pi)); 
    end
    
    % 4D Unwrapping
    n_u4 = unwrap_4D(phi);
    
    % 3D Unwrapping
    n_u3 = zeros(size(n_u4), 'int8');
    for i = 1:size(phi,4)
        n_u3(:,:,:,i) = unwrap_3D(phi(:,:,:,i));
    end
    
    results(:,:,i_SNR, i_venc, nt) = compare_results(n_true, n_u4, n_u3, masks);
end
end
end

%%

display_tables(results, list_SNR, list_venc)
% save('results.mat', 'results', '-v7.3');
