function [opacity,intensity] = compute_opacity_intensity(input_image,sky_image,sun_color_components)
%COMPUTE_OPACITY_INTENSITY compute the opacity and intensity of the
%clouds
%   input_image is the original image after sun filtered
%   sky_image is the image of the sky after reconstruction
%   sun_color_components is the RGB components of the sun
%   input_image and sky_image are of the same size w*h*3
%   opacity and intensity are the grayscale images of the opacity and 
%   intensity computed for the clouds with the size w*h

if nargin < 3
    sun_color_components = [1.0,1.0,1.0];
end
    
sun_color_components = double(sun_color_components);
[width,height,c] = size(sky_image);
opacity = zeros(width,height);
intensity = zeros(width,height);

for i = 1 : width
    for j = 1 : height
        denominator = sun_color_components(2)*sky_image(i,j,3)-sun_color_components(3)*sky_image(i,j,2);
        opacity(i,j) =(sun_color_components(2)*input_image(i,j,3)-sun_color_components(3)*input_image(i,j,2))/denominator;
        intensity(i,j) = (sky_image(i,j,3)*input_image(i,j,2)-sky_image(i,j,2)*input_image(i,j,3))/denominator;
    end
end

end
