function [ allBlobAreas] = sub_find_blobs( grayscale_image, mask )
    %Purpose: separates only the blobs with white pixels and finds their
    %areas
    % Original code was written and posted by ImageAnalyst, July 2009.
    % http://www.mathworks.com/matlabcentral/fileexchange/25157-image-segmentation-tutorial-blobsdemo/content/BlobsDemo.m

    %INPUT ARGUMENTS:
        %grayscale_image
        %mask - high threshold (0.99) mask, with (mainly) only the sun 
    %OUTPUT ARGUMENTS:
        %allBlobAreas - Returns the areas of all blobs
    
        
    BW = grayscale_image;
    BW3 = mask;
    labeledImage = bwlabel(BW3, 8);     % Label each blob so we can make measurements of it

    % Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
    blobMeasurements = regionprops(labeledImage, BW, 'all');   
    numberOfBlobs = size(blobMeasurements, 1);


    blobECD = zeros(1, numberOfBlobs);
    % Print header line in the command window.
    fprintf(1,'Blob #      Mean Intensity  Area   Perimeter    Centroid       Diameter\n');
    % Loop over all blobs printing their measurements to the command window.
    for k = 1 : numberOfBlobs           % Loop through all blobs.
        % Find the mean of each blob.  (R2008a has a better way where you can pass the original image
        % directly into regionprops.  The way below works for all versions including earlier versions.)
        thisBlobsPixels = blobMeasurements(k).PixelIdxList;  % Get list of pixels in current blob.
        meanGL = mean(BW(thisBlobsPixels)); % Find mean intensity (in original image!)

        blobArea = blobMeasurements(k).Area;		% Get area.
        blobPerimeter = blobMeasurements(k).Perimeter;		% Get perimeter.
        blobCentroid = blobMeasurements(k).Centroid;		% Get centroid.
        blobECD(k) = sqrt(4 * blobArea / pi);					% Compute ECD - Equivalent Circular Diameter.
        fprintf(1,'#%2d %17.1f %11.1f %8.1f %8.1f %8.1f % 8.1f\n', k, meanGL, blobArea, blobPerimeter, blobCentroid, blobECD(k));
        % Put the "blob number" labels on the "boundaries" grayscale image.
        %text(blobCentroid(1) + labelShiftX, blobCentroid(2), num2str(k), 'FontSize', fontSize, 'FontWeight', 'Bold');
    end

    allBlobAreas = [blobMeasurements.Area];


end

