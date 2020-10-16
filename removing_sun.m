function [filtered_image,sun_x,sun_y,sun_radius] = removing_sun(cropped_image,threshold,filter_color,beta,sun_present)
    %Purpose: Find the blobs in the image and define if there is a sun or not.
        % IF there is put Gausian filter + home made filter 
    
    %INPUT ARGUMENTS
        %color_cropped_image - the cropped color image (with vignette)
        %cropped_image - the cropped color image (without vignette)
    %OUTPUT ARGUMENTS:
        %img - Returns the areas of all blobs
        %grayscale_img - Filtered grayscale image ready to use for the mask
      
    [Y,X,C] = size(cropped_image);
    
    if nargin < 2
       threshold = 0.90;
       filter_color = [93/255, 113/255, 138/255];
       beta = 3.0;
       sun_present =  true;
    elseif nargin >= 4 && nargin < 5
       sun_present =  sun_present;
    end

    binarised_image = im2bw(cropped_image,threshold);
    

    

        
    current_image = binarised_image;
    iteration_count = 0;
    white_pixel_found = 1;
    while white_pixel_found == 1
        previous_image = current_image;
        current_image = imerode(current_image,strel('disk',1));
        iteration_count = iteration_count+1;
        white_pixel_found = ~isempty(find(current_image, 1));
    end

    if sun_present == false;
        filtered_image =  cropped_image;
    else
         
        %Get the sun centre and radius
        [y,x] = find(previous_image);
        sun_x = round(mean(x));
        sun_y = round(mean(y));
        sun_radius = iteration_count;

        sun_intensity = squeeze(cropped_image(sun_y,sun_x,:))';
        %alpha = [alpha_r, alpha_g, alpha_b];
        ampli_gauss = (1-filter_color) .* sun_intensity;
        sigma = beta.*sun_radius;
        sigma_squared = sigma*sigma;

        filtered_image = cropped_image;


        for x = 1 : X
            for y = 1 : Y
                xx = (double(x)-sun_x)*(double(x)-sun_x);
                yy = (double(y)-sun_y)*(double(y)-sun_y);
                r = xx+yy;
               tmp = exp(-1.*r./sigma_squared);
               filtered_image(y,x,1) = filtered_image(y,x,1)-filtered_image(y,x,1) * ampli_gauss(1)*tmp;
               filtered_image(y,x,2) = filtered_image(y,x,2)-filtered_image(y,x,2) * ampli_gauss(2)*tmp;
               filtered_image(y,x,3) = filtered_image(y,x,3)-filtered_image(y,x,3) * ampli_gauss(3)*tmp;
            end
        end
    end
    
%     %Convert to greyscale
%     greyscale_image = rgb2gray(uint8(cropped_image));     
%     [X,Y] = size(greyscale_image);
% 
%     %Binarise the greyscale image
%     binarised_image = im2bw(greyscale_image,threshold);
%     
%     %Erode the binarised image
%     current_image = binarised_image;
%     iteration_count = 0;
%     white_pixel_found = 1;
%     while white_pixel_found == 1
%         previous_image = current_image;
%         current_image = imerode(current_image,strel('disk',1));
%         iteration_count = iteration_count+1;
%         white_pixel_found = 0;
%         for x = 1 : X
%             for y = 1 : Y
%                 if current_image(x,y) == 1;
%                     white_pixel_found = 1;
%                 end
%             end
%         end
%     end
%     
%     %Get the sun centre and radius
%     [x,y] = find(previous_image);
%     sun_x = round(mean(x));
%     sun_y = round(mean(y));
%     sun_radius = iteration_count;
%     
%     %Create the gaussian function 
%     gauss = zeros(X,Y,3);
%     sun_intensity = uint8(color_cropped_image(sun_x,sun_y,:));
%     alpha = zeros(3);
%     alpha(1) = alpha_r;
%     alpha(2) = alpha_g;
%     alpha(3) = alpha_b;
%     ampli_gauss = zeros(3);
%     ampli_gauss(1) = alpha(1).*sun_intensity(1);
%     ampli_gauss(2) = alpha(2).*sun_intensity(2);
%     ampli_gauss(3) = alpha(3).*sun_intensity(3);
%     sigma = beta.*sun_radius;
%     denominator = 2.*sigma.*sigma;
%     sun_radius_square = sun_radius*sun_radius;
%     for x = 1 : X
%         for y = 1 : Y
%             xx = (double(x)-sun_x).*(double(x)-sun_x);
%             yy = (double(y)-sun_y).*(double(y)-sun_y);
%             r = xx+yy;
%             if r > sun_radius_square
%                tmp = -1.*r./denominator;
%                gauss(x,y,1) = ampli_gauss(1).*exp(tmp);
%                gauss(x,y,2) = ampli_gauss(2).*exp(tmp);
%                gauss(x,y,3) = ampli_gauss(3).*exp(tmp);
%             end
%         end
%     end
%     filtered_image(:,:,:) = color_cropped_image(:,:,:)-gauss(:,:,:);
%     
%     %Set the sun pixels as pure blue
%     x1 = uint16(sun_x-sun_radius);
%     x2 = uint16(sun_x+sun_radius);
%     y1 = uint16(sun_y-sun_radius);
%     y2 = uint16(sun_y+sun_radius);
%     for x = x1 : x2
%         for y = y1 : y2
%             xx = (double(x)-sun_x).*(double(x)-sun_x);
%             yy = (double(y)-sun_y).*(double(y)-sun_y);
%             r = xx+yy;
%             if r <= sun_radius_square
%                filtered_image(x,y,1) = 0;
%                filtered_image(x,y,2) = 0;
%                filtered_image(x,y,3) = 255;
%             end
%          end
%     end
        
end

