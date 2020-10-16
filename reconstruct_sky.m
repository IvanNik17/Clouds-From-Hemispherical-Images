function [ img ] = reconstruct_sky( img, mask, tile_size, min_i, k )
%RECONSTRUCT_SKY reconstructs the sky in areas masked by mask
%   img = RECONSTRUCT_SKY(img,mask) reconstructs with default values
%   img = RECONSTRUCT_SKY(img,mask,tile_size,min_i,k) reconstructs with
%   tiles of tile_size x tile_size and a minimum intensity of
%   references values of min_i in all channels; k is the number of nearest
%   neighbors for the reconstructing of reference values

if nargin < 2
    tile_size = 50;
    min_i     = 0.08;
    k         = 200;
end

[Y, X, C] = size(img);

mask = imerode(mask, strel('disk',4));


% Find positions with sky values

positions = zeros(X*Y,2);
counter = 0;
for y = 1:Y
   for x = 1:X
      if (mask(y,x) == 1) && all(img(y,x,:) > min_i)
        counter = counter+1;
        positions(counter,:) = [x,y];
      end
   end
end


positions = positions(1:counter,:);


% reconstruct color on reference points (tile edges)

for y1 = 1:floor(Y/tile_size)
    for x1 = 1:floor(X/tile_size)
        x = tile_size*x1;
        y = tile_size*y1;

        if (mask(y,x) == 0) || ~(all(img(y,x,:) > min_i))
            distances = sqrt((positions(:,1)-x).*(positions(:,1)-x)+(positions(:,2)-y).*(positions(:,2)-y));
            [sorted_values,sort_index] = sort(distances(:)); 
            indecies = sort_index(1:k);
            values = sorted_values(1:k);
            sum_values = sum(1./values);
            kkn_positions = positions(indecies,:);  
            color = zeros(1,1,3);
            for i = 1:k
                color = color + ((1./values(i))/sum_values) .* img(kkn_positions(i,2),kkn_positions(i,1),:);
            end

            img(y,x,:) = color;
            img(y-1,x,:) = color;
            img(y,x-1,:) = color;
            img(y-1,x-1,:) = color;
        end
    end
end

% interpolate between reference points

for y = 1:Y
    for x = 1:X
        if (mask(y,x) == 0)
            y1 = floor(y/tile_size)*tile_size;
            x1 = floor(x/tile_size)*tile_size;
            
            y2 = ceil(y/tile_size)*tile_size;
            x2 = ceil(x/tile_size)*tile_size;
            
            if y1 == 0
                y1 = tile_size;
            end
            
            if x1 == 0
                x1 = tile_size;
            end
            
            if y2 > Y
                y2 = y2-tile_size;
            end
            
            if x2 > X
                x2 = x2-tile_size;
            end
            
            c1 = abs(y1-y)/tile_size*img(y2,x1,:)+(1-(abs(y1-y)/tile_size))*img(y1,x1,:);
            c2 = abs(y1-y)/tile_size*img(y2,x2,:)+(1-(abs(y1-y)/tile_size))*img(y1,x2,:);

            img(y,x,:) = abs(x1-x)/tile_size*c2+(1-(abs(x1-x)/tile_size))*c1;
        end
    end
end

%G = fspecial('gaussian',[15 15],2);
%img = imfilter(img,G,'same');

end

