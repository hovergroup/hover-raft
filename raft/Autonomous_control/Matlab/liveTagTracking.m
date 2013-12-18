clear;
close all;

imaqreset;
% obj = videoinput('winvideo',2,'MJPG_800x448');  % Pedro's machine
% obj = videoinput('winvideo',1,'RGB24_640x480');  % Pedro's machine
% obj = videoinput('winvideo',2,'MJPG_1280x720');  % Pedro's machine
obj = videoinput('winvideo',2,'M420_960x544');  % Pedro's machine
% obj = videoinput('winvideo',2,'M420_1280x720');  % Pedro's machine

original = imread('tag.png ');

original = rgb2gray(original);
try
    set(obj,'framesperTrigger',5,'TriggerRepeat',Inf);
    start(obj);
    
     while islogging(obj);
        tic;
        im = getdata(obj,1);
        flushdata(obj);
        
        distorted = im(:,:,1);
        
        try
            [t,theta,scale] = getTransform(distorted,original);
            if (0==scale)
                continue
            end
            
        catch exception
            hold off;
            imshow(im(:,:,1));
            drawnow;
            disp('ERROR:')
            disp(exception.message);
            continue
        end
        
        hold off;
        imshow(im(:,:,1));
        hold on;
        plot(t(1), t(2),'rx','MarkerSize',15,'LineWidth',3);
        T = toc;
        title(['Frame rate: ', num2str(1.0/T)]);
        drawnow;
    end
catch exception
    disp('ERROR:')
    disp(exception.message);
    % This attempts to take care of things when the figure is closed
    stop(obj);
    imaqreset
end