function [ T, theta, scale, success ] = getTransform( image, original )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%   
%   Based on the MathWorks example available at
%   http://www.mathworks.com/help/vision/examples/find-image-rotation-and-scale-using-automated-feature-matching.html

    persistent pointsOriginal;
    persistent featuresOriginal;
    persistent validPointsOriginal;
    
    % Step 0: define default/fall-back values;
    T = zeros(2,1);
    theta = 0;
    scale = 0;
    success = 1;
   
    % Step 1: detect features
    if isempty(pointsOriginal)
       pointsOriginal =  detectSURFFeatures(original);
       [featuresOriginal, validPointsOriginal] = extractFeatures(original, pointsOriginal);    
       disp(['pointsOriginal: ',num2str(size(pointsOriginal,1))]);
       disp(['validPointsOriginal: ',num2str(size(pointsOriginal,1))]);
       disp(['featuresOriginal: ',num2str(size(pointsOriginal,1))]);
    end
    pointsImage =  detectSURFFeatures(image);
    [featuresImage, validPointsImage] = extractFeatures(image, pointsImage);
   
    % Step 2: match features
    indexPairs = matchFeatures(featuresOriginal, featuresImage);
    
    % Step 3: retrieve locations for matches
    matchedOriginal  = validPointsOriginal(indexPairs(:,1));
    matchedImage = validPointsImage(indexPairs(:,2));
   
    if ( 1>=size(matchedOriginal,1) || 1 >= size(matchedImage,1) )
        success = 0;
        %disp('failed to find sufficient points');
        return
    end
    
%     figure;
%     showMatchedFeatures(original,image,matchedOriginal,matchedImage);
%     title('Matched features');
    
    % Step 4: estimate transform
    %[tform, inlierImage, inlierOriginal] = estimateGeometricTransform(...
    %matchedImage, matchedOriginal, 'similarity');
    [tform, ~, ~] = estimateGeometricTransform(...
    matchedImage, matchedOriginal, 'similarity');

    Tinv  = tform.invert.T;

    ss = Tinv(2,1);
    sc = Tinv(1,1);
    scale = sqrt(ss*ss + sc*sc);
    theta = atan2(ss,sc);
  
%     disp(rad2deg(theta))
%     disp(scale)
%     disp('-------');
    T(1) = Tinv(3,1) + 60*scale*cos(-theta+pi/4);
    T(2) = Tinv(3,2) + 60*scale*sin(-theta+pi/4);
end

