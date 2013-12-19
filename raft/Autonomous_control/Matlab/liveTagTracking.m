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

    % config:pvt
    % obj = videoinput('winvideo',2,'MJPG_800x448');
    % obj = videoinput('winvideo',1,'RGB24_640x480');
    obj = videoinput('winvideo',2,'MJPG_1280x720');
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

% s = serial('COM5');
% set(s,'BaudRate', 57600);
% set(s,'ByteOrder','bigEndian');
% fopen(s);

%% Marker

original = imread('tag.png ');
original = rgb2gray(original);

%% Pre-allocation

successes = 0;  % stores number of frames for which we could track the raft
failures = 0;   % the ones for which we couldn't
count = 0;      % how many in total?

preallocate = 1000; % state vector length
x = zeros(3, preallocate); 
v1 = zeros(3, preallocate); 
v5 = zeros(3, preallocate); 

%% Main loop
try
    start(obj);

    % pvt: there's probably a way to write this loop so that it performs
    % faster. Perhaps using a sub-loop that goes through each frame set?
    while islogging(obj);
        tic;
        count = count + 1;
        im = getdata(obj, 1, 'uint8' );
        flushdata(obj);
        
        distorted = rgb2gray(im);
        
        [t,theta,scale, success] = getTransform(distorted,original);
        
        if (0==success)
            color = 'b';
            failures = failures + 1;
            if(count > 1)
                x(:, count) = x(:,count-1); % hold
            end
        else
            successes = successes + 1;
            color='r';
            x(:, count) = [t; theta];
        end
        
        
        if (count > 6)
            v1(:,count) = x(:,count) - x(:,count-1);
            v5(:,count) = mean(diff(x(:,count-4:count),1,2),2);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BEGIN: RUN CONTROL LOOP HERE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % END: RUN CONTROL LOOP HERE %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
         
        figure(1);
        % PLOT: POSITION
        subplot(2,2,1)
%          hold off;
%         imshow(im(:,:,1));
%         hold on;
        if(count<100)
            plot(x(1,1:count), x(2,1:count), [color,'.'], 'MarkerSize', 15,'LineWidth',3);
        else
            plot(x(1,(count-99):count), x(2,(count-99):count), [color,'.'], 'MarkerSize', 15,'LineWidth',3);
        end
        xlabel('x [px]')
        ylabel('y [px]')
        xlim([0 1279])
        ylim([0 719])
        grid on
        T = toc;
        title(['Frame rate: ', num2str(1.0/T), ' S/F: ', num2str(successes), '/', num2str(failures)]);
        
        % PLOT: HEADING
        subplot(2,2,2)
        if(count<100)
            plot(rad2deg(x(3,1:count)),['-',color,'.'],'LineWidth',3);
        else
            plot((count-99):count,rad2deg(x(3,(count-99):count)),['-',color,'.'],'LineWidth',3);
        end
        ylabel('Heading [deg]');       
        grid on
        
        if(count > 6)
            % PLOT: VELOCITY
            subplot(2,2,3)
            if(count<100)
                hold off;
                plot((v5(1,1:count)),['-',color,'.'],'LineWidth',3);
                hold on
                plot((v5(2,1:count)),['--',color,'.'],'LineWidth',3);
            else
                                hold off;
                plot((count-99):count,(v5(1,(count-99):count)),['-',color,'.'],'LineWidth',3);
                hold on
                plot((count-99):count,(v5(2,(count-99):count)),['--',color,'.'],'LineWidth',3);
            end
            ylabel('Speed [px/s]');       
            grid on

            % PLOT: YAW RATE
            subplot(2,2,4)
            if(count<100)
                hold off;
                plot(rad2deg(v5(3,1:count)),['-',color,'.'],'LineWidth',3);
            else
                hold off;
                plot((count-99):count,rad2deg(v5(3,(count-99):count)),['-',color,'.'],'LineWidth',3);
            end
            ylabel('Yaw rate [rad/s]');       
            grid on            
        end
        drawnow;
        
        % resize state vector
        if size(x,2)-count < 100
            x = [x, zeros(3, preallocate)];
            disp('REALLOC!');
        end
     end
catch exception
    disp('ERROR:')
    disp(exception.message);
    disp('FILE:')
    disp(exception.stack.file);
    disp('LINE:')
    disp(exception.stack.line);
    stop(obj);
    imaqreset
end