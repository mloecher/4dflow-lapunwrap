function save_slice(phi, n_u4, n_u3, prefix, slice, t)

if (nargin < 5), slice=128; end
if (nargin < 6), t=7; end

im1 = phi(:,:,slice,t);

scale = [-pi pi];
dscale = diff(scale);

im1 = im1 - scale(1);
im1 = im1./dscale;
im1(im1<0) = 0;
im1(im1>=1) = 1;

imwrite(imresize(im1, 10, 'nearest'), sprintf('%s_%s', prefix, 'orig.png'))

im2 = phi(:,:,slice,t) + 2*pi .* double(n_u4(:,:,slice,t));
im3 = phi(:,:,slice,t) + 2*pi .* double(n_u3(:,:,slice,t));

scale = [-pi 2*pi];
dscale = diff(scale);

im2 = im2 - scale(1);
im2 = im2./dscale;
im2(im2<0) = 0;
im2(im2>=1) = 1;

imwrite(imresize(im2, 10, 'nearest'), sprintf('%s_%s', prefix, 'u4.png'))

im3 = im3 - scale(1);
im3 = im3./dscale;
im3(im3<0) = 0;
im3(im3>=1) = 1;

imwrite(imresize(im3, 10, 'nearest'), sprintf('%s_%s', prefix, 'u3.png'))