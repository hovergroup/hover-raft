mexmoos('CLOSE');
mexmoos('init','SERVERHOST','localhost','SERVERPORT','9000');

pause(1);

mexmoos('REGISTER','ECA_WRIST_SPEED',0);
mexmoos('REGISTER','ECA_WRIST_POSITION',0);

time = zeros(1,1);
speed = zeros(1,1);
position = zeros(1,1);
command = zeros(1,1);

speed_index = 1;
position_index = 1;
exit = 0;
tic;
while (exit==0)
    msgs=mexmoos('FETCH');
    
    if (toc < 1)
        mexmoos('NOTIFY','ECA_WRIST_VOLTAGE_CMD',0);
        cmd = 0;
    end
    if (toc > 1)
        cmd = sin((toc-1)*2*pi*1)*50;
        mexmoos('NOTIFY','ECA_WRIST_VOLTAGE_CMD',cmd);
    end
    
    if (~isempty(msgs))
        for k=1:length(msgs)
            if(strcmp(msgs(k).KEY,'ECA_WRIST_SPEED'))
                speed(speed_index)=msgs(k).DBL;
                time(speed_index) = toc;
                command(speed_index) = cmd;
                speed_index = speed_index+1;
            elseif(strcmp(msgs(k).KEY,'ECA_WRIST_POSITION'))
                position(position_index)=msgs(k).DBL;
                position_index = position_index+1;
            end
        end
    end
    
    if (abs(position_index-speed_index)>1)
        fprintf('error indices separated')
        exit = 1;
    end
    
    if (toc > 5)
        mexmoos('NOTIFY','ECA_WRIST_VOLTAGE_CMD',0);
        exit = 1;
    end 
end

mexmoos('CLOSE');

close all;
position = position-position(1);
%position = -position;
subplot(211);
plot(time,speed,time,abs(command*max(speed)/50))
subplot(212);
plot(time,position,'k')
grid;