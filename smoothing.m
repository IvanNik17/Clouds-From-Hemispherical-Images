function [ smooth_image ] = smoothing( input_image )
%Smoothing function gets the image and applies two types of interpolation
%on the intensity values for each pixel. The first is applied only if the
%pixel intensity is 0 and the other one when they are different from 0. The
%output is a image with smoother bounderies.




[width,height] = size(input_image);
smooth_image = input_image;

%Smoothing of values
    for x = 2:width
       for y = 2:height
            if x < width && y < height && smooth_image(x,y) == 0 
                corners = (smooth_image(x-1, y-1)+smooth_image(x+1, y-1) + smooth_image(x-1, y+1)+smooth_image(x+1, y+1) ) / 12;
                sides   = (smooth_image(x-1, y)  +smooth_image(x+1, y)  + smooth_image(x, y-1)  +smooth_image(x, y+1)) /  6;
                %center  =  smooth_image(x, y)/ 4;
                smooth_image(x,y) = corners + sides;% + center;

%             elseif x < width && smooth_image(x,y) ~= 0
%                 previous = smooth_image(x-1,y);
%                 next = smooth_image(x+1,y);
%                 smooth_image(x,y) = previous*0.5 + next*0.5;
% 
%             elseif y < height && smooth_image(x,y) ~= 0
%                 previous = smooth_image(x,y-1);
%                 next = smooth_image(x,y+1);
%                 smooth_image(x,y) = previous*0.5 + next*0.5;

            elseif x < width && y < height && smooth_image(x,y) ~= 0
                   y_1 = y-1;
                   x_1 = x-1;

                   y_2 = y+1;
                   x_2 = x+1;
                   
                   c1 = 0.5*smooth_image(x_1,y_1)+0.5*smooth_image(x_2,y_1);
                   c2 = 0.5*smooth_image(x_1,y_2)+0.5*smooth_image(x_2,y_2);
                   
                   temp = 0.5*c2+0.5*c1;
%                    smooth_image(x,y) = (temp + smooth_image(x,y))/2;
                   smooth_image(x,y) = mean([temp smooth_image(x,y)]);
            end
       end
    end
    
end

