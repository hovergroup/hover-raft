function [dataOUT]=readTankCamLog(filename,xRes,yRes)
% read Tank Cam logfile and plot data
% INPUTS:
% string <filename> (filename.txt log file)
% xRes and yRes (camera resolution)
% OUTPUT: struct with data 

% notes:
% right now colors for up to 6 rafts...

% BR, 11/10/2010
% changelog:
%{
- author, date: change
- BR 2/17/2011: changed marker edge color to match fill
- BR 3/3/2011: added options for which plots, added theta to main plot
-%RAH 10/24/2011 - added ability to trim the beginning out of a log file (the
% startPacketNumber variable indicates the packet number of the first data
% point)
%}

fid=fopen([filename,'.txt']);

%% read in data

% read parameters
% data1=textscan(fid,'%s',1);

% read data:
% 'ID:,%i,x:,%f,y:,%f,theta:,%f,xdot:,%f,ydot,%f'
data=textscan(fid,'%*s %f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %f %*s %f',...
    'delimiter',',');
fclose(fid);

%% parse data from cell

packNum=data{1};
packets=unique(packNum);
startPacketNumber = min(packets);
numPackets=max(packets) - startPacketNumber + 1;
% if(length(packets)~=packets(numPackets));
%     disp('packets don''t match up')
%     %return
% end

time=data{2};
tvec=unique(time);
% if(length(tvec)~=numPackets);
%     disp('times don''t match up')
%     %return
% end

IDData=data{3};
numBlobs=max(IDData);

xData=data{4};
yData=data{5};
thetaData=data{6};
xdotData=data{7};
ydotData=data{8};

x=zeros(numPackets,numBlobs);
y=zeros(numPackets,numBlobs);
theta=zeros(numPackets,numBlobs);
xdot=zeros(numPackets,numBlobs);
ydot=zeros(numPackets,numBlobs);

%% sort data

for i=1:length(IDData)
    id=IDData(i);
    thisPackNum=packNum(i) - startPacketNumber + 1;
    %
    x(thisPackNum,id)=xData(i);
    y(thisPackNum,id)=yData(i);
    theta(thisPackNum,id)=thetaData(i);
    xdot(thisPackNum,id)=xdotData(i);
    ydot(thisPackNum,id)=ydotData(i);
end

% post process

for i=1:numPackets
    for j=1:numBlobs
        if(x(i,j)==0 && y(i,j)==0)
            x(i,j)=NaN;y(i,j)=NaN;
        end
    end
end


% send data back to workspace in structure
dataOUT=struct('packets',packets,'time',tvec,'x',x,'y',y,'theta',theta,...
    'xdot',xdot,'ydot',ydot);

%% plots

% which plots to show:
posPlot=1;
trajPlot=1;
velPlot=1;
timePlot=1;

% setup colors
c=[0 .75 .75];
g=[0 0.5 0];
m=[0.75 0 0.75];
colorlist={'b',g,'r',c,m,'k'};

if(posPlot)
    figure(111)
    subplot(3,1,1)
    plot(tvec,x','--.')
    title('x positions')
    xlabel('time [s]')
    ylabel('x [pixels]')
    legend('1','2','3','4','5','6')
    
    subplot(3,1,2)
    plot(tvec,y','--.')
    title('y positions')
    xlabel('time [s]')
    ylabel('y [pixels]')
    legend('1','2','3','4','5','6')
    
    subplot(3,1,3)
    plot(tvec,(theta)','--.')
    title('heading')
    xlabel('time [s]')
    ylabel('theta [deg]')
    legend('1','2','3','4','5','6')
end

if(trajPlot)
    figure(222)
    for i=1:numBlobs
        plot(-y(:,i),x(:,i),'--d','MarkerFaceColor',colorlist{i},...
            'MarkerEdgeColor',colorlist{i},'MarkerSize',5)
        hold on
    end
    grid on
    title('tracks')
    ylabel('x (window edge) [pixels]')
    xlabel('-y (away from window) [pixels]')
    axis equal
    yRes = 480; xRes = 640;
    axis([-yRes 0 0 xRes]);
end

if(timePlot)
    dt=tvec(2:length(tvec))-tvec(1:length(tvec)-1);
    figure(333)
    plot(tvec(2:length(tvec)),dt,'b.')
    title('complete loop times')
end

if(velPlot)
    figure(444)
    subplot(2,1,1)
    plot(tvec,xdot','--.')
    title('xdot')
    legend('1','2','3','4','5','6')
    subplot(2,1,2)
    plot(tvec,ydot','--.')
    title('ydot')
    legend('1','2','3','4','5','6')
end

