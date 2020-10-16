function [ masked_image ] = sub_mask_over_image( input_image, mask, resize_scale )
%Function puts the mask over the image, so only the clouds are visible


masked_image = input_image;
masked_image(:,:,1) = immultiply(input_image(:,:,1), mask);
masked_image(:,:,2) = immultiply(input_image(:,:,2), mask);
masked_image(:,:,3) = immultiply(input_image(:,:,3), mask);

masked_image = rgb2gray(masked_image);

if nargin == 3
    masked_image = imresize(masked_image,resize_scale);
end

end

