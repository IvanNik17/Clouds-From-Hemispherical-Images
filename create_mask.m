function [ msk ] = create_mask( img, threshold )
%CREATE_MASK creates a mask for sky images; sky black, clouds white
%   mask = CREATE_MASK(img) creates a mask with default values
%   mask = CREATE_MASK(img,amount_croma,min_i) creates a mask with customs
%   values. amount_chroma specifies the minimum amount of chroma for a
%   pixel considered as sky; min_i specifies the minimum itentensity on
%   maximum channel for a pixel to be considered as colored

    if nargin < 2
        threshold = 12;
    end

    min_img = min(min(img(:,:,1), img(:,:,2)), img(:,:,3));
    max_img = max(max(img(:,:,1), img(:,:,2)), img(:,:,3));

    [grad_x,grad_y] = gradient(rgb2gray(img));

    grad = max(abs(grad_x), abs(grad_y));

    max_v = max(grad(:));
    min_v = min(grad(:));

    grad = (grad-min_v)/max_v;

    O = 6;

    for i = 1:O
        grad = imdilate(grad, strel('disk',1));
    end

    for i = 1:O
        grad = imerode(grad, strel('disk',1));
    end

    msk = ceil((max_img-min_img)./max_img-threshold*grad); 
    msk(isnan(msk)) = 0;
    msk(msk<0) = 0;
    msk = logical(msk);
end