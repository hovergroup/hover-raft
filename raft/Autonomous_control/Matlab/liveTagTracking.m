%% 
%{
    Marker-based tracking

    Pedro Vaz Teixeira [HoverGroup] 2013
    pvt@mit.edu
%}
%% Clean-up

clear all;
close all;
clc;

%% Set-up capture
try
    imaqreset;

    % config:raft
%     obj = videoinput('winvideo',1,'M420_640x360');  
%     obj = videoinput('winvideo',1,'M420_640x480');  
    obj = videoinput('winvideo',1,'M420_800x448');  
%     obj = videoinput('winvideo',1,'M420_960x544');    
%     obj = videoinput('winvideo',1,'M420_1280x720');

%     obj = videoinput('winvideo',1,'MJPG_640x360');  
%     obj = videoinput('winvideo',1,'MJPG_640x480');  
%     obj = videoinput('winvideo',1,'MJPG_800x448');  
%     obj = videoinput('winvideo',1,'MJPG_960x544');    
%     obj = videoinput('winvideo',1,'MJPG_1280x720');

    obj = videoinput('winvideo',1,'YUY2_800x448');  

    % config:pvt
%     obj = videoinput('winvideo',2,'MJPG_800x448');
%     obj = videoinput('winvideo',1,'RGB24_640x480');
%     obj = videoinput('winvideo',2,'MJPG_1280x720');
%     obj = videoinput('winvideo',2,'M420_960x544');

    obj.FramesPerTrigger =1;
    obj.TriggerRepeat = Inf;
    obj.ReturnedColorspace = 'rgb';
    
    src = getselectedsource(obj);
    src.BacklightCompensation = 'off';
    src.Contrast = 10;
    src.ExposureMode='manual';
    src.Exposure = -7;      % -13 to 0 (low to high)
    src.FocusMode='manual';
    src.Focus = 0;          % seems to work ok with our FOV
    src.FrameRate = '30.0000';
    pause(1);
catch exception
    disp('ERROR:')
    disp(exception.message);
    stop(obj);
    imaqreset
    return
end

%% Raft communication

s = serial('COM3');
set(s,'BaudRate', 57600);
set(s,'ByteOrder','bigEndian');
fopen(s);

%% Marker

original = imread('tag.png ');
original = rgb2gray(original);

%% Pre-allocation

successes = 0;  % stores number of frames for which we could track the raft
failures = 0;   % the ones for which we couldn't
count = 0;      % how many in total?

preallocate = 10000; % state vector length
t = zeros(1, preallocate); 
x = zeros(3, preallocate); 
v1 = zeros(3, preallocate); 
v5 = zeros(3, preallocate);
scale = zeros(1, preallocate);
u = zeros(4, preallocate);
xdes = [300 300 90]; %xdes, ydes, thetades

%% Main loop
% try
    start(obj);

    % pvt: there's probably a way to write this loop so that it performs
    % faster. Perhaps using a sub-loop that goes through each frame set?
    tic;
    while islogging(obj);
        count = count + 1;
        im = getdata(obj, 1, 'uint8' );
        t(count) = toc;
        flushdata(obj);
        
        distorted = rgb2gray(im);
        
        [translation, theta, scale(count), success] = getTransform(distorted, original);
        
        if (0==success)
            color = 'r';
            failures = failures + 1;
            if(count > 1)
                x(1:3, count) = x(1:3,count-1); % hold
            end
        else
            successes = successes + 1;
            color='b';
            x(1:3, count) = [translation; theta];
        end
        
        if (count > 6)
%             v1(:,count) = x(1:3,count) - x(1:3,count-1);
%             v1(:,count) = v1(:,count) * (1/(t(count) - t(count-1)));
            v5(:,count) = mean(diff(x(1:3,count-4:count),1,2),2);
            v5(:,count) = v5(:,count) * (4/(t(count) - t(count-4)));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BEGIN: RUN CONTROL LOOP HERE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%             u(:,count) = headingControl(t, x, v5);
            %u(:,count) = positionControl(t, x, v5);

            % fcn to map control signal to thrusters
            % [thrust, direction] = mapToThruster(u);

            % fcn to assemble telecommand packet
%             commandPacket = assembleCommandPacket(thrust, direction);

            % fwrite(s,uint8(commandPacket));

            % run control loop
            uOut = raftcontrolxy2(x(:,count),v5(:,count),xdes,0);
            %uOut = raftcontrol2(x(:,count),v5(:,count),xdes,0);
        
            % send commands to raft
            fwrite(s,uint8(uOut))
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % END: RUN CONTROL LOOP HERE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            plotAll(t, x, v5, count, color, successes, failures);    
        
%             disp(count/toc);
            disp(scale(count));
            % resize state vector
            if size(x,2)-count < 100
                t = [t, zeros(1, preallocate)];
                x = [x, zeros(3, preallocate)];
                v1 = [v1, zeros(3, preallocate)];
                v5 = [v5, zeros(3, preallocate)];
            end
        end
     end
% catch exception
%     disp('ERROR:')
%     disp(exception.message);
%     disp('FILE:')
%     disp(exception.stack.file);
%     disp('LINE:')
%     disp(exception.stack.line);
%     stop(obj);
%     imaqreset
%     fclose(serialPort);
%     delete(serialPort);
% end

%% POST

figure(2);
B = [x(1:2,:);scale];
scatter3(B(1,:),B(2,:),B(3,:));
title('Scaling')
xlabel('x [px]')
ylabel('x [px]')
zlabel('scale [px/px]')
