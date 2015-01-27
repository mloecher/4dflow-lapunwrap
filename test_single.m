%% TEST_SINGLE.m Test unwrapping method for a given SNR and ven
%

%%
clear all
clc

addpath('utils');
addpath('unwrap')

%% Settings

SNR = 8; 
venc = .4;

%% Unwrap

% Generate phantom
[VEL, MAG, MASKS] = gen_phantom([512 512]);
[IM, Vref, masks] = make_phantom_3d(VEL, MAG, MASKS, [256 256], 1, 256, venc, SNR);

phi = angle(IM);

% 4D Unwrapping
tic
n_u4 = unwrap_4D(phi);
toc

% 3D Unwrapping
n_u3 = zeros(size(n_u4), 'int8');
tic
for i = 1:size(phi,4)
    n_u3(:,:,:,i) = unwrap_3D(phi(:,:,:,i));
end
toc

%% Display results
display_slice(phi, n_u4, n_u3);

% prefix = sprintf('SNR%.1f_venc%.1f', SNR, venc);
% save_slice(phi, n_u4, n_u3, prefix);