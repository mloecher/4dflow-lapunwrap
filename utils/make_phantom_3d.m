function [IM, VELr, masks] = make_phantom_3d(VEL, MAG, MASKS, resize_dims, crop_flag, n_slices, venc, SNR )
%% MAKE_PHANTOM_3D Takes the 2D phantom and makes it 3D
% Takes the idealized 2D Wommersley phantom and make it into a simulated MR
% imaging volume with noise.
%
% Args:
%     VEL: 2D x timeframes matrix of velocity information
%     MAG: 2D matrix of magnitudes
%     MASK: 2D array giving location of vessels with a label
%     resize_dims: The intended xy dimensions of the phantom 
%     crop_flag: Crop the data by a factor of 3 in the xy dimension
%     n_slices: Number of slices in the z direction
%     venc: venc relative to 1.0
%     SNR: SNR level
% 
% Returns:
%     IM: Complex wrapped output volume
%     VELr: resized and cropped 2D reference velocities
%     masks: resized and cropped masks

%% 
num_frames = size(VEL, 3);

%% Make the data complex

VELr = VEL .* pi ./ venc; % convert to angle in radians
IM = repmat(MAG, [1 1 num_frames]) .* exp(1j.*VELr);

%% Resize image
%  Assumes that the 2D input is high resolution for more accuracy
%  Crop in k-space for realism (some ringing at vessel walls and partisl volume)
%  Going back to image space isnt strictly necessary, but makes excitation
%  simulation slightly more realistic.

K = ifftshift(fft2(fftshift(IM)));
r1 = (1:resize_dims(1)) + (size(K,1)-resize_dims(1))/2;
r2 = (1:resize_dims(2)) + (size(K,2)-resize_dims(2))/2;
mod = (size(K,1)-resize_dims(1))/size(K,1) * (size(K,2)-resize_dims(2))/size(K,2);
K = K(r1, r2, :) .* mod;
IM = ifftshift(ifft2(fftshift(K)));

% Also resize the reference velocity so we have a 'truth'
K = ifftshift(fft2(fftshift(VELr)));
r1 = (1:resize_dims(1)) + (size(K,1)-resize_dims(1))/2;
r2 = (1:resize_dims(2)) + (size(K,2)-resize_dims(2))/2;
K = K(r1, r2, :) .* mod;
VELr = real(ifftshift(ifft2(fftshift(K))));

%% Resize the masks with imresize
%  because we dont want ringing or anything in these

masks = zeros([resize_dims 4], 'single');
for i = 1:4
   masks(:,:,i) = imresize(MASKS(:,:,i), resize_dims); 
end

thresh = 0.5;

masks(masks<thresh) = 0;
masks(masks>0) = 1;

masks = int8(masks);

%% Crop
% This is to speed up the algorith, crop the data to only include the 
% vessels.  This doesnt change the results, just speeds things up by ~9
% Reducing by a factor of 3 is hardcoded to leave the vessels with some
% border

if crop_flag
    new_size = round(size(IM,2)/3)+1;
    r2 = (1:new_size) + round((size(IM,2)-new_size)/2);

    IM = IM(r2,r2,:);
    VELr = VELr(r2,r2,:);
    masks = masks(r2,r2,:);
end

%% Make 3D

IM = permute(IM, [1 2 4 3]);
IM = repmat(IM, [1 1 n_slices 1]);

%% Excitation 
%  This is important to make the unwrapping simulation realistic because
%  of the importance of boundary conditions.  Because we are using FFTs the
%  periodicity in the z-direction is unrealistic compared to an in vivo
%  case, so we add a fake and idealized excitation profile where the signal
%  goes to zero.  Subsequently, we dont include these areas in the
%  analysis.

cutoff = 6;

excite = ones([n_slices 1], 'single');
excite(1:cutoff) = 0;
excite(end-cutoff-1:end) = 0;
w = gausswin(9);
w = w./sum(w(:));
excite = conv(excite,w,'same');

IM = IM .* repmat(permute(excite, [2 3 1]), [size(IM,1) size(IM,2) 1 size(IM,4)]);

%% Add noise

noise_scale = sqrt(numel(IM(:,:,:,1)))/SNR;

for i = 1:num_frames
   K = ifftshift(fftn(fftshift(IM(:,:,:,i))));
   K = K + noise_scale.*(randn(size(K)) + 1j.*randn(size(K)));
   IM(:,:,:,i) = ifftshift(ifftn(fftshift(K)));
end

end

