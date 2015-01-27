function display_slice(phi, n_u4, n_u3, slice, t)

if (nargin < 4), slice=128; end
if (nargin < 5), t=7; end

im1 = phi(:,:,slice,t);
im2 = phi(:,:,slice,t) + 2*pi .* double(n_u4(:,:,slice,t));
im3 = phi(:,:,slice,t) + 2*pi .* double(n_u3(:,:,slice,t));

figure(); 

imshow([im1 im2 im3], [], 'border', 'tight', 'InitialMagnification', 300)

text(.16, 1.0, 'Wrapped', 'Units', 'normalized', 'color', 'white', ...
               'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
               'VerticalAlignment', 'top', 'FontSize', 14)
text(.5, 1.0, '4D Laplacian', 'Units', 'normalized', 'color', 'white', ...
               'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
               'VerticalAlignment', 'top', 'FontSize', 14)
text(.84, 1.0, '3D Laplacian', 'Units', 'normalized', 'color', 'white', ...
               'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
               'VerticalAlignment', 'top', 'FontSize', 14)