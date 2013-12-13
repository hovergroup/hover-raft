function control = raftcontrol(theta,thetaOld,dt,thetades, thetaError,IError)

%Simple PID controller for raft heading, for testing purposes

Kp = 5;
Kd = 2;
Ki = 0;
% dt = 0.1;
% thrustmax = pi;
offset = 30; %to account for motor not moving for commands less than offset
thrust = -Kp*(thetaError) - Kd*(theta - thetaOld)/dt - Ki*IError;

if thrust>255-offset
    thrust=255-offset;
elseif thrust<=-(255-offset)
    thrust = -(255-offset);
end

%now convert thrust to m1d,m1s,m2d,...,m5s
% m1s = abs(thrust)+offset;
% m1d = 2+sign(thrust);
% m2s = abs(thrust)+offset;
% m2d = 2-sign(thrust);
% m3s = m2s;
% m3d = 2+sign(thrust);
% m4s = m2s;
% m4d = 2-sign(thrust);
% m5s = 0;
% m5d = 0;

m1s = 53;
m1d = 1;
m2s = 0;
m2d = 1;
m3s = 125;
m3d = 3;
m4s = 0;
m4d = 3;
m5s = 0;
m5d = 0;

control = uint8(['<';'[';'(';m1s; m1d; m2s; m2d; m3s; m3d; m4s; m4d; m5s; m5d;')';']';'>']);
