function [VEL, MAG, MASKS] = gen_phantom(matrix_size, num_frames)
%% GEN_PHANTOM Generates a flow phantom for unwrapping
% 
% Creates a digital flow pahntom using the Womersley method.  Flow field is
% 2D and returns dynamic velocity values.  Because it is ideal flow the
% velocity vector is entirely into the plane.
%
% Args:
%     matrix_size: 2D array giving size of the phantom, this might not work
%       if the sizes aren't equal (not tested)
%     num_frames: number of timeframes, defaults to 30
% 
% Returns:
%     VEL: matrix with the velocities
%     MAG: matrix with magnitude values
%     MASKS: mask of each vessel (matrix_size x 4) 


%%
if (nargin < 2), num_frames=24; end

%% Womersley Arterial Flow coefficients

C0 = -25;
D = 400;
C = [7.58 5.41 1.52 0.52 0.83 0.69 0.26 0.54 0.27 0.10];
Phi = [-174 89 -22 -34 -127 135 152 44 -72 11];
Phi = Phi/180*pi;

coeff = D.*C.*exp(1i.*Phi);

mu = 4e-3; % viscosity Pa*s
ro = 1.06e3; % density kg/m^3
nu = mu/ro; % viscosity m^2/s
omega = 2*pi;

%% Location of the vessels
ves_sep_m = .025; % Seperation (meters)
ves_sep  = ves_sep_m*matrix_size(1)/.3; % convert to pixels

ves_rad = [.02 .015 .01 .005]; % meters

x_cent = matrix_size(1)/2;
ves_x = [x_cent+ves_sep x_cent+ves_sep x_cent-ves_sep x_cent-ves_sep];
y_cent = matrix_size(2)/2;
ves_y = [y_cent+ves_sep y_cent-ves_sep y_cent+ves_sep y_cent-ves_sep];

ves_rad_p = ves_rad .* matrix_size(1)/.3; % FOV = 30 cm, assuming isotropic voxels

%% Set up some really basic background signal

MAG = zeros(matrix_size, 'single');
meshspace1 = linspace(-.5, .5, matrix_size(1));
meshspace2 = linspace(-.5, .5, matrix_size(2));
[XX, YY] = meshgrid(meshspace1, meshspace2);
R = sqrt(XX.^2 + YY.^2);

MAG(R<.45) = .7;

%% Storage for vessel masks
MASKS = zeros([matrix_size 4], 'single');


%% Calculate velocity values for each vessel

VEL = zeros([matrix_size num_frames], 'single');

for vi = 1:numel(ves_rad)
    for x=floor(ves_x(vi)-ves_rad_p(vi)-2):floor(ves_x(vi)+ves_rad_p(vi)+2)
        for y=floor(ves_y(vi)-ves_rad_p(vi)-2):floor(ves_y(vi)+ves_rad_p(vi)+2)
            
            rad1= sqrt( (x-ves_x(vi))^2+(y-ves_y(vi))^2);
            if(rad1 < ves_rad_p(vi))
                MAG(x,y) = 1.0;
                MASKS(x,y,vi) = 1.0;
                for p = 1:num_frames
                    
                    t_sel = (p - 1 )/num_frames;
                    alpha = sqrt(ro*omega*ves_rad(vi)^2/mu);
                    rhat = rad1/ves_rad_p(vi);
                    
                    n = 1:10;
                    ex = 1i^(3/2).*sqrt(n).*alpha;
                    vt = coeff.*(ves_rad(vi)^2./1j./n./mu./alpha^2).*(1 - besselj(0,ex.*rhat)./besselj(0,ex) ).*exp(1i.*n.*omega.*t_sel);
                    Velocity = sum(vt);
                    Velocity = Velocity + C0*ves_rad(vi)^2/4/mu*(1-rhat^2);
                    VEL(x,y,p) = -real(Velocity);
                    
                end
            end
            
        end
    end
end

%% Add some minor blurring
% Even with the Fourier resizing we do later and the higher resolution
% phantom, the jagged and infinetely sharp edges aren't realistic, so we do
% very minor blurring to fix the vessel walls.

G = fspecial('gaussian', [9 9], 1);

MAG = imfilter(MAG, G, 'same');

for i = 1:num_frames
    VEL(:,:,i) = imfilter(VEL(:,:,i), G, 'same');
end

%% Normalize peak velocities to 1.
%  Note that this changes pressure->velocity relationship a little from
%  Womersley, but this should be unrelated to unwrapping performance.
%  This also means that smaller vessels have different flow profiles than
%  the larger, but this is realistic.

for i = 1:4
    xr=floor(ves_x(i)-ves_rad_p(i)-2):floor(ves_x(i)+ves_rad_p(i)+2);
    yr=floor(ves_y(i)-ves_rad_p(i)-2):floor(ves_y(i)+ves_rad_p(i)+2);
    data = VEL(xr, yr, :);
    VEL(xr, yr, :) = VEL(xr, yr, :)./max(data(:));
end



end

