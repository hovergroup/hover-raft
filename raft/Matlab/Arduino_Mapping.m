clear all

%% Create Bode Plot of Arm's Velocity Response

% Initialize MOOS

mag  = zeros(1,1);
phase = zeros(1,1);
phase_lag = zeros(1,1);
amplitude_ratio = zeros(1,1);

ans='connecting to arduino...'
a = arduino('/dev/ttyACM0','uno');
ans='connected!'

    
mexmoos('CLOSE');
pause(1);
mexmoos('init','SERVERHOST','localhost','SERVERPORT','9000');
pause(1);

mexmoos('REGISTER','ECA_SHOULDER_SPEED',0);
mexmoos('REGISTER','ECA_SHOULDER_POSITION',0);

time = zeros(1,1);
speed = zeros(1,1);
position = zeros(1,1);
command = zeros(1,1);
av = zeros(1,1);
pottime = zeros(1,1);

speed_index = 1;
position_index = 1;
exit = 0;
tic;
while (exit==0)
    msgs=mexmoos('FETCH');

    if (toc < 1)
        mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',0);
        cmd = 0;
    end
    if (toc > 1)
        cmd = -50;
        mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',cmd);
    end

    if (~isempty(msgs))

        for k=1:length(msgs)
            if(strcmp(msgs(k).KEY,'ECA_SHOULDER_SPEED'))
                speed(speed_index)=msgs(k).DBL;
                time(speed_index) = toc;
                command(speed_index) = cmd;
                speed_index = speed_index+1;
            elseif(strcmp(msgs(k).KEY,'ECA_SHOULDER_POSITION'))
                av(position_index)=readVoltage(a,0);
                pottime(position_index) = toc;
                position(position_index)=msgs(k).DBL;
                position_index = position_index+1;
            end
        end
    end

    if (abs(position_index-speed_index)>1)
        fprintf('error indices separated')
        exit = 1;
    end

    if (toc > 2)
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
        newcom(index)=command(a);
        newpos(index)=currentpos;
        newvel(index)=speed(a);
        newtime(index)=time(a);
        index=index+1;
    end
end




%% Use this if you are taking manual derivatibe of position
newpos=(newpos-min(newpos));
speed_fit = diff(newpos)./diff(newtime);
speed_fit= abs(speed_fit);
newspd = speed_fit*max(newvel)/(max(speed_fit)*120);
newcom = abs((newcom(2:end)-mean(newcom(2:end))));
newtime = newtime(2:end);
newpos = newpos-min(newpos);
position = position-min(position);
newpos = newpos(2:end);
newvel = newvel(2:end)./120;

[~,idx]=find(time==newtime(1));
potVolt = (-av(idx:end)-min(-av(idx:end))).*1000;
potTime = pottime(idx:end);
plot(potTime,potVolt);

potP = polyfit(time(idx:end),av(idx:end),1);
potSlope = potP(1)

posP = polyfit(newtime,newpos,1);
posSlope = posP(1)

%% StringPot voltage to Endcoder position value:

posSlope/potSlope % = -5352.8
