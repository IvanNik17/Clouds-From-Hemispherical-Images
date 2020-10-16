function [ cropped_image ] = crop_image( originalImage, offset_x, offset_y, radius )
%Cropping the image and applying vignette
    %INPUT ARGUMENTS:
        %originalImage - Mirrored ball close-up image
    %OUTPUT ARGUMENTS:
        %cropped_image - cropped image

%LOAD THE IMAGE
[x, y, z] = size(originalImage);

%CROP THE IMAGE
if nargin < 2
    radius = 1525;
    offset_x     = 45;
    offset_y     = 20;
end

start_x = x/2+offset_x;
start_y = y/2-offset_y;

cropped_image = originalImage(start_x-radius:start_x+radius,start_y-radius:start_y+radius,:);

end

