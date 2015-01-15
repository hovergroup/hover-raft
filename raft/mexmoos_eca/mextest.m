mexmoos('CLOSE');
mexmoos('init','SERVERHOST','localhost','SERVERPORT','9000');

pause(1);

mexmoos('REGISTER','ECA_YAW_SPEED',0);
mexmoos('REGISTER','ECA_YAW_POSITION',0);

time = zeros(1,1);
speed = zeros(1,1);
position = zeros(1,1);

speed_index = 1;
position_index = 1;
exit = 0;
tic;
while (exit==0)
    msgs=mexmoos('FETCH');
    
    if (~isempty(msgs))
        for k=1:length(msgs)
            if(strcmp(msgs(k).KEY,'ECA_YAW_SPEED'))
                speed(speed_index)=msgs(k).DBL;
                time(speed_index) = toc;
                speed_index = speed_index+1;
            elseif(strcmp(msgs(k).KEY,'ECA_YAW_POSITION'))
                position(position_index)=msgs(k).DBL;
                position_index = position_index+1;
            end
        end
    end
    
    if (toc > 3)
        mexmoos('NOTIFY','ECA_YAW_VOLTAGE_CMD',100);
    elseif (toc > 1)
        mexmoos('NOTIFY','ECA_YAW_VOLTAGE_CMD',30);
    else
        mexmoos('NOTIFY','ECA_YAW_VOLTAGE_CMD',0);
    end
    
    if (abs(position_index-speed_index)>1)
        fprintf('error indices separated')
        exit = 1;
    end
    
    if (toc > 5)
        mexmoos('NOTIFY','ECA_YAW_VOLTAGE_CMD',0);
        exit = 1;
    end 
end

mexmoos('CLOSE');

close all;
position = position-position(1);
%position = -position;
plotyy(time,position,time,speed);
grid;