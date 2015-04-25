clear all

%% Find scaling between potentiometer and arm position reading

% Initialize MOOS

disp('connecting to arduino...')
a = arduino('/dev/ttyACM0','uno');
disp('connected!')

    
mexmoos('CLOSE');
pause(1);
mexmoos('init','SERVERHOST','localhost','SERVERPORT','9000');
pause(1);

time = zeros(1,1);
speed = zeros(1,1);
position = zeros(1,1);
command = zeros(1,1);
av = zeros(1,1);
pottime = zeros(1,1);

speed_index = 1;
position_index = 1;
exit = 0;
zeroed = 0;

disp('Zeroing arm...')
while (exit==0)
    msgs=mexmoos('FETCH');
    
    while (zeroed==0)
        if (readVoltage(a,0) < 4.8)
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',-100);
        else
            zeroed=1;
            disp('Zeroed!')
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',0);
            mexmoos('CLOSE');
            pause(1);
            mexmoos('init','SERVERHOST','localhost','SERVERPORT','9000');
            pause(1);
            mexmoos('REGISTER','ECA_SHOULDER_POSITION',0);
            tic;
        end
    end
    
    mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',100);
    

    if (~isempty(msgs))    
        for k=1:length(msgs)
            if (strcmp(msgs(k).KEY,'ECA_SHOULDER_POSITION'))
                av(position_index)=readVoltage(a,0);
                pottime(position_index) = toc;
                time(position_index) = toc;
                position(position_index)=msgs(k).DBL;
                position_index = position_index+1;
            end
        end
    end


    if (readVoltage(a,0) < 0.1)
        mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',0);
        exit = 1;
    end
    

    pause(0.01);
end

mexmoos('CLOSE');

close all;


newpos = [];
newvel = [];
newtime = [];
newcom = [];
index = 1;

currentpos = -8888888;
currentvel = -8888888;

for a=1:length(position)
    if position(a)~=currentpos
        currentpos=position(a);
        newpos(index)=currentpos;
        newtime(index)=time(a);
        index=index+1;
    end
end




%% Use this if you are taking manual derivatibe of position
newpos=(newpos-min(newpos));

[~,idx]=find(time==newtime(1));
potVolt = (-av(idx:end)-min(-av(idx:end))).*1000;
potTime = pottime(idx:end);
plot(potTime,potVolt);

potP = polyfit(time(idx:end),av(idx:end),1);
potSlope = potP(1)

posP = polyfit(newtime,newpos,1);
posSlope = posP(1)

%% StringPot voltage to Endcoder position value:

pot2pos = posSlope/potSlope; % = -1.0955*10^4 -1.0957*10^4 -1.0966*10^4
