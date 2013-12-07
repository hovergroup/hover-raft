%{
    Camera-based tracker for the raft
    
    HoverGroup/PVT (2013)
%}

clear;
close all;
imaqreset;

% obj = videoinput('winvideo',1,'RGB24_320x240');
obj = videoinput('winvideo',1,'RGB24_424x240');
min_area = 50;
max_area = 200;

% obj = videoinput('winvideo',1,'RGB24_640x360');

% obj = videoinput('winvideo',1,'RGB24_800x448');
% min_area = 400;
% max_area = 600;

% obj = videoinput('winvideo',1,'RGB24_640x480');

T=1;
losses = 0;

try
    set(obj,'framesperTrigger',5,'TriggerRepeat',Inf);
    start(obj);

    a = obj.VideoResolution;
    height = a(2);
    width = a(1);
    x = zeros(1,2);
    xBlobs = zeros(3,2);
    %figure(1);
    
    while islogging(obj);
        tic;
        im = getdata(obj,1);
        flushdata(obj);

        imThresh = imcomplement( im2bw(im(:,:,1), 0.75));            
        rp = regionprops(imThresh, 'Area', 'Eccentricity', 'Centroid');

        for i=size(rp,1):-1:1
            if ( (rp(i).Area < min_area) || (rp(i).Eccentricity > 0.4) || (rp(i).Area > max_area) )
                rp(i) = [];
            end
        end
                      
        % this part could be improved...
        if ( size(rp,1)==3 )
            x = zeros(1,2);
            plot(x);
            
            hold on
            for i = 1:size(rp,1)
                xBlobs(i,1) = rp(i).Centroid(1);
                xBlobs(i,2) = rp(i).Centroid(2);
                plot(xBlobs(i,1), xBlobs(i,2),'ko', 'MarkerSize', 10, 'LineWidth',2);
                x = x + rp(i).Centroid;
            end
            x = (1/size(rp,1))*x;
            plot(x(1), x(2), 'bo', 'MarkerSize', 12, 'LineWidth',4);
            hold off
        elseif(~isempty(rp))
            plot(zeros(2,1));
            hold on
            for i = 1:size(rp,1)
                plot(rp(i).Centroid(1), rp(i).Centroid(2), 'ro', 'MarkerSize', 10, 'LineWidth',2);
            end
            for i=1:3
                plot(xBlobs(i,1), xBlobs(i,2),'ko', 'MarkerSize', 10, 'LineWidth',2);
            end
            plot(x(1), x(2), 'ro', 'MarkerSize', 12, 'LineWidth',4);
            hold off
            % draw in red since we lost packets!
        end
        
        title(['Frame rate: ', num2str(1.0/T)]);
        xlim([0, width]);
        ylim([0, height]);
        drawnow;

        T = toc;
    end
catch exception
    disp('ERROR:')
    disp(exception.message);
    % This attempts to take care of things when the figure is closed
    stop(obj);
    imaqreset
end