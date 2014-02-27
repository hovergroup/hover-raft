%% 
%{
    Marker-based tracking

    Pedro Vaz Teixeira [HoverGroup] 2013
    pvt@mit.edu
%}
%% Clean-up

% if(exist('serialPort'))
%     fclose(serialPort)
%     delete(serialPort)
%     clear SerialPort
% end
% 
% if(exist('obj'))
%     stop(obj)
%     delete(obj)
%     imaqreset
% end

clear all;
close all;
clc;

%% Set-up capture
try
    imaqreset;

    % config:raft
%     obj = videoinput('winvideo',1,'M420_640x360');  
%     obj = videoinput('winvideo',1,'M420_640x480');  
%     obj = videoinput('winvideo',1,'M420_800x448');  
    obj = videoinput('winvideo',1,'M420_960x544');    
%     obj = videoinput('winvideo',1,'M420_1280x720');

%     obj = videoinput('winvideo',1,'MJPG_640x360');  
%     obj = videoinput('winvideo',1,'MJPG_640x480');  
%     obj = videoinput('winvideo',1,'MJPG_800x448');  
%     obj = videoinput('winvideo',1,'MJPG_960x544');    
%     obj = videoinput('winvideo',1,'MJPG_1280x720');

%     obj = videoinput('winvideo',1,'YUY2_800x448');  

    % config:pvt
%     obj = videoinput('winvideo',2,'MJPG_800x448');
%     obj = videoinput('winvideo',1,'RGB24_640x480');
%     obj = videoinput('winvideo',2,'MJPG_1280x720');
%     obj = videoinput('winvideo',2,'M420_960x544');

    obj.FramesPerTrigger =1;
    obj.TriggerRepeat = Inf;
    obj.ReturnedColorspace = 'rgb';
    
    imageSize = obj.VideoResolution;
    
    imageWidth = imageSize(1);
    imageHeight = imageSize(2);
    
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

serialPort = serial('COM3');
set(serialPort,'BaudRate', 57600);
set(serialPort,'ByteOrder','bigEndian');
fopen(serialPort);

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
%xdes = [394 120 0]; %xdes, ydes, thetades
utheta = 0;
uthetasave = zeros(1,preallocate);
xest = [0 0 0]';
xestsave = zeros(3,preallocate);
lossvec = zeros(1,preallocate);
gsim = zeros(3,1);
psisim = zeros(3,1);
Yk1k1 = eye(3,3);
Ykk1 = eye(3,3);
uout = zeros(1,4);
yout = zeros(1,4);

%% Goals
% xDesired(:,1) = [200 300 -pi/2]';   % hold point
% xDesired(:,2) = [600 300 -pi/2]';   % hold point
% xDesired(:,3) = [600 200 -pi/2]';   % hold point
% xDesired(:,4) = [400 200 -pi/2]';   % hold point
% xDesired(:,5) = [394 120 -pi/2]';   % drill

xDesired(:,1) = [494 250 -pi/2]';   % hold point
xDesired(:,2) = [494 250 -pi/2]';   % drill
currentGoal = 1;

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

            
            if(count > 11)
                positionError = mean(abs(x(1:3,count-9:count) - repmat(xDesired(:,currentGoal),1,10)),2);
                if ( positionError(1)<20 && positionError(2)<20 && positionError(3) < deg2rad(0.1) )
                    disp('Reached:');
                    xDesired(:,currentGoal)
                    disp('Error:')
                    positionError
                    if(currentGoal<size(xDesired,2))
                        currentGoal = currentGoal+1;
                        disp('Next waypoint:');
                        xDesired(:,currentGoal)
                    else
                        disp('Task complete');
                        stop(obj);
                        imaqreset
                        fclose(serialPort);
                        delete(serialPort);
                        clear serialPort;
                        clear obj;  
                        break;
                    end
                end
            end

            % run control loop
            IError = x(:,count) - xDesired(:,currentGoal);
            %thrustvec = headingControl(0,x(1,count),0.1);
            %thrustvec = raftcontrolxy3(x(:,count),v5(:,count),xDesired(:,currentGoal),IError);
            %thrustvec = ConstThrust(count);
            %[control1, control2, control3, xest, utheta, loss, gsim, psisim,Yk1k1,Ykk1] = HeadingControlMIF(x(:,count),xest,utheta,gsim,psisim,Yk1k1,Ykk1);
            %[control1, control2, control3, xest, utheta, loss, gsim, psisim] = HeadingControlMIFconstY(x(:,count),xest,utheta,gsim,psisim);
            %[control1, control2, control3, xest, utheta, loss] = HeadingControlLQG(x(:,count),xest,utheta);
            %---LZ, LH
            [control1, control2, control3, yout, uout, loss] = HeadingControlLZLH(x(:,count),yout,uout);
            xest(1,count) = yout(1);
            utheta = uout(1);
            %---
            %uthetasave(count) = utheta;
            %xestsave(:,count) = xest;
            lossvec(count) = loss;
            thrustvec = [control1 control2 control3];
            
            
            [thrust, direction] = mapToThruster(thrustvec(1), thrustvec(2), thrustvec(3), x(3,count));
            commandPacket = assembleCommandPacket(thrust, direction);
           
            % send commands to raft
            fwrite(serialPort,uint8(commandPacket))
        
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % END: RUN CONTROL LOOP HERE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
            plotAll(t, x, v5, count, color, successes, failures, imageWidth, imageHeight );    

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
x = x(:,1:count);
figure(2);
B = [x(1:2,:);scale];
scatter3(B(1,:),B(2,:),B(3,:));
title('Scaling')
xlabel('x [px]')
ylabel('x [px]')
zlabel('scale [px/px]')
figure(3)
plot(rad2deg(x(3,:)))