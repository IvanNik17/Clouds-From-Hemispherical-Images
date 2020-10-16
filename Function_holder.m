clear all;
close all;

input_dir = 'Input_images/';
output_dir = 'Result_images/';
name = '119';
img = im2double(imread(strcat(input_dir, 'XP7U0', name, '.jpg')));

%1) CROP + VIGNETTE
cropped_image  = vignette(crop_image(img));

figure('Name',' Crop and vignette'), imshow(cropped_image);
imwrite(cropped_image, strcat(output_dir, name, '_cropped_image.jpg'));

%RESIZE
cropped_image = imresize(cropped_image,[2000,2000]);

%2) REMOVING OF THE SUN  
img_sun_removed = removing_sun(cropped_image,0.90,[104/255, 130/255, 155/255],2.0,true);


figure('Name',' Sun removed'), imshow(img_sun_removed);
imwrite(img_sun_removed, strcat(output_dir, name, '_img_sun_removed.jpg'));
figure('Name',' Sun only'), imshow(imsubtract(cropped_image, img_sun_removed));


%3) CREATING MASK

mask  = create_mask(img_sun_removed,12);

figure('Name',' Mask'), imshow(mask);
imwrite(mask, strcat(output_dir, name, '_mask.jpg'));

%4) RECONSTRUCTING SKY
sky = reconstruct_sky(img_sun_removed,mask,1000,0.08,100);

figure('Name',' Reconstructed sky'), imshow(sky);
imwrite(sky, strcat(output_dir, name, '_sky.jpg'));

% 5) INTENSITY + OPACITY
[opacity,intensity] = compute_opacity_intensity(img_sun_removed,sky);

figure('Name',' Intensity'), imshow(intensity);
figure('Name',' Opacity'), imshow(opacity);

imwrite(1-opacity, strcat(output_dir, name, '_opacity_mask.jpg'));


%6) SMOOTHING VALUES
[ smooth_image ] = smoothing( intensity );

figure('Name',' Smoothed intensity'), imshow(smooth_image);

%7) CURVING + CREATE .OBJ FILE

[C,X,Y,Z] = saveobjmesh(smooth_image,name,1000);

set(0, 'DefaultFigureRenderer', 'OpenGL');
figure('Name',' 3D mesh');
shading interp;
surf(X,Y,Z,'EdgeColor','none','LineStyle','none','FaceLighting','phong', 'FaceColor', 'interp');

