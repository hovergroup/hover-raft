% Tank Camera Tracking main program
% Interfaces with SwisTrack over TCP/IP localhost
% Reads in string of particle locations, angles and velocities
% Plots locations in realtime
% logs data in txt file named by date and time
% BR, 11/10/2010
%
% Currently configured for Microsoft LifeCam Studio running with
% SwisTrack's openCV driver, limited to 640x480 resolution
% Coordinates are given in terms of 1-225 tank
% x is along the window edge of tank, positive to the S (twds Boston)
% y is along the edge in the center of the room, positive away from window

% 2/15/2011 BR - began to add ground-truth tracking algorithms
% 2/17/2011 BR - changed output of parseTrack to measOUT vector, error
% checking on measurement (empty matrices)
%              - 
% 3/3/2011 - changed this to check for stopflag in main loop (not fcn)
% 3/3/2011 - modified this to tankCamTrack FUNCTION to be used with
% tankRaftMain script  (stopping development of this fcn - works though)

% fclose(s)
% delete(s)
clear all;close all;clc;
format compact;

%% CONFIG PARAMETERS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% print data stream to terminal?
print=0;
% delete log after final plots (use this for testing/debugging)?
deleteLog=0;
% number of vehicles to track: (MAKE SURE THIS MATCHES SWISSTRACK)
numBlobs=3;


%% MORE CONFIG PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% timing (in ms):
loopDelay=0;
%loopTime=120;       %this is MIN loop time (delay until this)
loopTime=0;

% tracking method
trackMethod='simpleNN';     % no KF - just associates meas with vehicle
%trackMethod='noControlKF'; % KF for update (smoothing), no prediction
%trackMethod='fullKF';      % KF with control for predict, with update

% KF parameters
%Q=1;
%R=1;
%A,B,C
% plan to make KFmodel a cell with params...
KFmodel=0;

% folder to save logfiles in:
% logFolder='C:\Brooks\My Dropbox\1Raft Code\Raft Matlab\Raft Logs';
% oldFolder=cd(logFolder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Real Time Plotting:
plotTime=1;         %log and plot times used only for plotting

%realtimePlotCase='all';
% plots all values (always hold on)
% plotting (and thus overall loop) gets slower with time...

%realtimePlotCase='none';
% plot nothing (still keep figure up to catch ESC => stopflag)

realtimePlotCase='new';
% plots newest updates (holds one set of vehicle positions)

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%camera parameters:
xRes=640;   % x is N-S (width of tank, // window)
yRes=480;   % y is E-W (length of tank, 1~9ft from window)
h=initRealTimePlot;

TCPIPPort=3000;

% potential stopping parameters (if not using ESC)
% tFinal=10;          %s
% numPackets=10;

%% setup logfile and ports

%init timing vector (for debugging code run speed)
if(plotTime);dtPlot=zeros(1,10000);k=0;end

% init log files: filename is date and time - input to fcn is prefix
% ground-truth tracking log:
% [fid,filename]=constructFile('GroundTruth');

% SwissTrack TCP/IP communication:
trackIn=tcpip('localhost',TCPIPPort);
% longest expected ~2300 bytes in 0.5 sec...
buffSize=3200;
set(trackIn, 'InputBufferSize', buffSize);
fopen(trackIn);

% XBee init



%% real-time run

stopflag=0;
packetsStart=tic;
packNum=0;
theta = 0;
roll = 0;
pitch = 0;
heading = 0;
thetaOld=0;
thetablobs=0;
thetablobsOld=0;
thetades = 90;
thetaError = 0;
IError = 0;
thetadotsave = zeros(1,1e3);
thetasave = zeros(1,1e3);
thetablobsave = zeros(1,1e3);
timevec=zeros(1,1e3);

% preallocate variables (5 states, column for each vehicle):
% x_i=[x xdot y ydot theta]'
numStates=5;
xOld=zeros(numStates,numBlobs);
xMeas=zeros(numStates,numBlobs);
xPlus=zeros(numStates,numBlobs);
uOld=zeros(2,numBlobs);
AOld = zeros(1,2);
DOld = zeros(1,2);


% send control commands to rafts:
s = serial('COM5');
set(s,'BaudRate', 57600);
set(s,'ByteOrder','bigEndian');
serialData = [];

%get(s);

fopen(s);

while(stopflag==0)
    
    time=toc(packetsStart);
    
    % get data from SwissTrack TCP/IP stream
    data=cameraTrackInput(trackIn,numBlobs);
    [numLines, b]=size(data);
    %if(print);fprintf('\nnew packet: \n');end
    packNum=packNum+1;
    fprintf('\npacket: %i\n',packNum)
    % data is 1 column cell array, read in packet lines (ignore stop)
    
    for i=1:numLines-1
        % uses numLines-1 because STEP_STOP is last line...
        % numLines-1 in packet should match numBlobs...
        if((numLines-1)~=numBlobs)
            fprintf('packet data and numBlobs do not match \n')
        end
        
        % Grab all data:
        %for i=1:numBlobs;
        if(print);fprintf(data{i,1});fprintf('\n');end
        % parse data cell into variables
        % currently SwissTrack's ID is meaningless...
        %[ID,xST,yST,thetaST,xdotST,ydotST]=parseTrack(data{i,1}',xRes,yRes);
        measOUT=parseTrack(data{i,1}',xRes,yRes);
        
        % error check:
        badData=0;
        if(length(measOUT)~=6)
            badData=1;
        end        
        for kk=1:length(measOUT)
            if(isempty(measOUT(kk)))
                badData=1;
            end
        end
        if(badData)
            % if bad data, discard and replace with previous estimate
            % could update this to only discard bad individual components
            measOUT=xPlus;
        end
        
        % fill up initial data vector (ID arbitrary at this point):
        % Initial ordering from SwissTrack sets vehicle IDs from here on...
        %xMeas(:,i)=[xST xdotST yST ydotST thetaST];
        xMeas(:,i)=measOUT(1:5)';
    end
     
    %initialization: starting prediction is 1st measurement:
    
    % now, uOld set in groundTruthTrack fcn
    %     if(strcmp(trackMethod,'fullKF'))
    %         uOld=uOut;
    %     % else uOld is still zeros...(never initialized)
    %     end
    
    % Tracking:
    % xPlus=groundTruthTrack(xOld,uOld,xMeas,trackMethod,KFmodel) %EWG comment
    
    % measurement allocation algorithms
    
    
    % compute control commands to raft
    pose = getPoseFromBlobs(xMeas);
    x = pose(1);
    y = pose(2);
    thetablobs = pose(3)*180/pi;
%discard outlier points
if abs(thetablobs-thetablobsOld)>40 && thetablobsOld~=0 && abs(thetablobs-thetablobsOld)<300
    thetablobs = thetablobsOld;
end

    if(s.BytesAvailable>0)
        serialData = [serialData; fread(s,s.BytesAvailable,'uint8')];
    end
    
    %todo: [success, roll, pitch, yaw] = parseRaftData(serialData);
 %------------------------------------------------------------------------------------------   
%     if(length(serialData)>=27)
%        % look for the last (latest) tuple of measurements 
%        indexRoll = find(char(serialData)=='R', 1, 'last');
%        indexPitch = find(char(serialData)=='P', 1, 'last');
%        indexHeading = find(char(serialData)=='H', 1, 'last');
%        
%        if length(serialData)-indexRoll < 9
%            indexRoll2 = find(char(serialData)=='R', 2, 'last')
%            indexRoll = indexRoll2(1)
%        end
%        
%        if length(serialData)-indexPitch < 9
%            iP2 = find(char(serialData)=='P', 2, 'last')
%            indexPitch = iP2(1)
%        end
%        
%        if length(serialData)-indexHeading < 9
%            iH2 = find(char(serialData)=='H', 2, 'last')
%            indexHeading = iH2(1)
%        end
%        
%        if (~isempty(indexRoll) && ~isempty(indexPitch) && ~isempty(indexHeading))
%           iRe = find(char(serialData(indexRoll:end))=='!', 1, 'first')
%           iPe = find(char(serialData(indexPitch:end))=='!', 1, 'first')
%           iHe = find(char(serialData(indexHeading:end))=='!', 1, 'first')
%           
%           if (~isempty(iRe) && ~isempty(iPe) && ~isempty(iHe))
%             %roll = serial
%               
%               r = serialData(indexRoll+2:indexRoll+iRe)
%             p = serialData(indexPitch+2:indexPitch+iPe)
%             head = serialData(indexHeading+2:indexHeading+iHe)
%             char(head)
%             % wat
%             
%             rsum=0;
%             psum=0;
%             hsum=0;
% %             for i=indexRoll-4:indexRoll-3
% %                 rsum = rsum+str2num(char(r(i)));
% %             end
% %             for i=iP-4:iP-3
% %                 psum = psum+str2num(char(p(i)));
% %             end
%             for i=1:iHe-6
%                 hsum = hsum+str2num(char(head(i)))*10^(iHe-6-i);
%             end
%               head2 = hsum + str2num(char(head(iHe-4)))*10^(-1)+str2num(char(head(iHe-3)))*10^(-2);
% %             roll = str2num(char(r(1)))+str2num(char(r(3)))*(1e-1)+str2num(char(r(4)))*(1e-2);
% %             pitch = str2num(char(p(2)))*(10)+str2num(char(p(3)))+str2num(char(p(5)))*(1e-1)+str2num(char(p(6)))*(1e-2);
% %             head2 = str2num(char(head(1)))*(1e2)+str2num(char(head(2)))*(10)+str2num(char(head(3)))+str2num(char(head(5)))*(1e-1)+str2num(char(head(6)))*(1e-2);
%              head3 = 180-head2-28; %heading offset of 18 degrees to make consistent with tank coords
% %              heading = head2;
%              if head3<0
%                  heading = head3*175/195;
%              else
%                  heading = head3*177/147;
%              end
%              if heading>180
%                  heading = 360-heading;
%              end
%              
% %             disp(['roll: ', num2str(roll)]);
% %             disp(['pitch: ', num2str(pitch)]);
%             disp(['heading: ', num2str(heading)]);
%             
%             serialData = [];
%           end      
%       end        
%     end
% 
%     theta = heading;
%--------------------------------------------------------------------------------------------
theta=thetablobs;    
thetadotsave(1,packNum) = (theta-thetaOld)/0.1;
    thetasave(1,packNum) = theta;
    thetablobsave(1,packNum) = thetablobs;
   dt = toc(packetsStart)-time;
   timevec(1,packNum) = toc(packetsStart);
    %END:TODO
    
    % BEGIN TODO: move control computation to dedicated function 
    % motors = headingControl(theta, theta_desired)
    % pose = [x y theta];
    % motors = poseControl(pose, desired_pose);
    thetaError = theta - thetades;
  
    if thetaError>pi
        thetaError = thetaError -2*pi;
    elseif thetaError<-pi
        thetaError = thetaError +2*pi;
    end
    IError = IError + thetaError;
    
    if IError > 3
        IError = 3;
    end
    
   
    if (badData) %|| a>40 || b>40 || d>40 
        %uOut = uint8(['<';'[';'(';0; 0; 0; 0; 0; 0; 0; 0; 0; 0;')';']';'>']);
        % hold previous value
        uOut = raftcontrol(thetaOld,thetaOld,dt,thetades,thetaError,IError);
    else
        %uOut = raftcontrolxy(theta,x,y)
         uOut = raftcontrol(theta,thetaOld,dt,thetades,thetaError,IError);
    end 
    % END:TODO
 
    % BEGIN: Write function that translates motor signals (assumed -1 to 1)
    % into a packet that is then sent over the serial port
    fwrite(s,uint8(uOut));
    % END:TODO

        % log and plot updated positions:
    for i=1:numBlobs
        ID=i;               % keep vehicles ordered
        x=xPlus(1,i);
        xdot=xPlus(2,i);
        y=xPlus(3,i);
        ydot=xPlus(4,i);
        alpha=xPlus(5,i);
        
        % log data to text file
%         fprintf(fid,'num:,%i,time:,%f,ID:,%i,x:,%f,y:,%f,theta:,%f,xdot:,%f,ydot,%f\n',...
%             packNum,time,ID,x,y,theta,xdot,ydot);
%         
        if(plotTime);plotStart=tic;k=k+1;end
        
        % plot in real time, check if ESC pressed to stop
        realtimePlotCam(realtimePlotCase,h,ID,xMeas(1,i),xMeas(3,i),...
            xRes,yRes,numBlobs,theta,thetaOld,packNum); 
        %realtimePlotCam(realtimePlotCase,h,ID,x,y,...
        %    xRes,yRes,numBlobs); 
        if(plotTime);dtPlot(k)=toc(plotStart);end
        
    end
    
    thetaOld = theta;
    thetablobsOld = thetablobs;   
%     AOld = A;
%     DOld = D; %store current measurement as AOld, DOld for next iteration

    % use this format:
    % +123.12 for x and y thrust (N)
    % fprintf('%+07.2f',a)
    
    
    % pure delay
    %pause(loopDelay/1000); 
    % constrain (roughly) to loopTime

%     while((toc(packetsStart)-time)<(loopTime/1000))
%         %fprintf('%0.3f\n',(toc(packetsStart)-time)) 
%     end

    % look for ESC key - stops script
    key=get(h,'CurrentKey');
    stopflag=isequal(key,'escape');
    
end
tFinal=toc(packetsStart);

fclose(s);

%% post-run
% close serial connection
flose(s);
delete(s);
% close log file
fclose(fid);
% close tcp/ip connection
fclose(trackIn);
delete(trackIn)
clear trackIn

fprintf('\nnumPackets = %i\n',packNum)
fprintf('tFinal = %f\n',tFinal);
fprintf('av. loop speed: %g [Hz]\n\n',packNum/tFinal)

% plot final results
dataFull=readTankCamLog(filename,xRes,yRes);

if(plotTime)
    figure
    inds2=find(dtPlot);
    dtPlot=dtPlot(inds2);
    plot(dtPlot,'b.')
    title('realtime plot dt')
end

if(deleteLog)
    delete([filename,'.txt']);
end

cd(oldFolder)
