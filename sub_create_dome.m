function [ dome_matrix, radius ] = sub_create_dome( input_image )
%Function gets an image and creates 

[width,height,color] = size(input_image);
  radius = width/2;
  [X,Y] = meshgrid(-width/2+1:1:width/2);
  dome_matrix = sqrt(radius^2 - (X.^2) - (Y.^2));
  dome_matrix = real(dome_matrix);

end

