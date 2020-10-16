function [ result ] = sub_filter_function( radius, rad_coefficient, x_size, y_size, x_center, y_center)
    %Purpose: Makes pyramid looking filter 
    
    %INPUT ARGUMENTS
        %radius - radius of the filter
        %rad_coefficient - coefficent needed for calculating the step value
        %x_size, y_size - the size of the filtered image
        %x_center, y_center - the center of the sun, where we put the filter
    %OUTPUT ARGUMENTS:
        %result - Returns image of the filter

    step = 1/(rad_coefficient*radius);

    matrix = zeros(radius,radius);

    x_value = 0;
    for i = 1:radius
        temp_value = 1 - x_value;
        for j = 1:radius
           temp_value = temp_value - step;
    %       y_value = y_value + step;
           matrix(i,j) = temp_value;
        end
        x_value = x_value + step;

    end

    rot270_matrix = rot90(matrix, 3);
    uppermatrices = [matrix, rot270_matrix];

    rot180_matrix = rot90(uppermatrices, 2);

    filter = [uppermatrices; rot180_matrix];

    new_filter = ones(x_size, y_size);
    new_filter(1:2*radius, 1:2*radius) = filter;
    new_filter = single(new_filter);
    new_filter = circshift(new_filter, [uint16(y_center)-radius, uint16(x_center)-radius]);

    result = new_filter;
 
end    