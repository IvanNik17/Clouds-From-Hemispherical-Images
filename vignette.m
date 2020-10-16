function [ vignette_cropped_image ] = vignette( originalImage )
%Cropping the image and applying vignette
    %INPUT ARGUMENTS:
        %originalImage - Mirrored ball close-up image (cropped)
    %OUTPUT ARGUMENTS:
        %vignette_cropped_image - cropped image with vignette applied


%LOAD THE VIGNETTE CROPPED FILTER
hdr = hdrread('VignetteMultiplyerCropped.hdr');
vignette = hdr;

vignette_cropped_image = double(immultiply(vignette,single(originalImage)));
end

