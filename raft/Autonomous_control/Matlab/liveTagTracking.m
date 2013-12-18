clear all;
close all;
clc;

imaqreset;
% obj = videoinput('winvideo',2,'MJPG_800x448');  % Pedro's machine
% obj = videoinput('winvideo',1,'RGB24_640x480');  % Pedro's machine
obj = videoinput('winvideo',2,'MJPG_1280x720');  % Pedro's machine
% obj = videoinput('winvideo',2,'M420_960x544');  % Pedro's machine
% obj = videoinput('winvideo',2,'M420_1280x720');  % Pedro's machine

original = imread('tag.png ');
original = rgb2gray(original);

lastKnownPosition = zeros(2,1);

successes = 0;
failures = 0;

try
    set(obj,'framesperTrigger',5,'TriggerRepeat',Inf);
    start(obj);
    
     while islogging(obj);
        tic;
        im = getdata(obj,1);
        flushdata(obj);
        
        distorted = im(:,:,1);
        
        [t,theta,scale] = getTransform(distorted,original);
        if (0==scale)
            marker = 'bx';
            failures = failures + 1;
        else
            successes = successes + 1;
            marker='rx';
            lastKnownPosition = t;
        end
        
%         hold off;
%         imshow(im(:,:,1));
%         hold on;
        plot(lastKnownPosition(1), lastKnownPosition(2),marker,'MarkerSize',15,'LineWidth',3);
        xlim([0 1279])
        ylim([0 719])
        T = toc;
        title(['Frame rate: ', num2str(1.0/T), ' Eric rate: ', num2str(successes/(successes+failures)), ' F: ', num2str(failures)]);
        drawnow;
    end
catch exception
    disp('ERROR:')
    disp(exception.message);
    % This attempts to take care of things when the figure is closed
    stop(obj);
    imaqreset
end