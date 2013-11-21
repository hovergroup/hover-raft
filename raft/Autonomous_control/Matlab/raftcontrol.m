function control = raftcontrol(theta,thetaOld,dt)

%Simple P controller for raft heading, for testing purposes
thetades=0;
Kp = 1;
Kd = 0.1;
thrustmax = pi*Kp;
thrust = -Kp*(theta-thetades)-Kd*(theta-thetaOld)/dt;

%now convert thrust to m1d,m1s,m2d,...,m5s
m1s = 0;
%m1s = floor(thrust/thrustmax*255);
m1d = 0;
m2s = abs(floor(thrust/thrustmax*255));
m2d = 2+sign(thrust);
m3s = 0;
m3d = 3;
m4s = m2s;
m4d = 2+sign(thrust);
m5s = 0;
m5d = 3;

% m1s = 127;
% %m1s = floor(thrust/thrustmax*255);
% m1d = 1;
% m2s = 127;
% m2d = 3;
% m3s = 127;
% m3d = 1;
% m4s = 127;
% m4d = 3;
% m5s = 0;
% m5d = 3;

control = uint8(['<';'[';'(';m1s; m1d; m2s; m2d; m3s; m3d; m4s; m4d; m5s; m5d;')';']';'>']);
%control = uint8(hex2dec(['3C'; '3C'; '3C'; '39'; '03'; '27'; '01'; '19'; '01'; '00'; '03'; '00'; '03'; '3E'; '3E'; '3E']));
%control = uint8([60 60 60 57 3 39 1 25 1 0 3 0 3 62 62 62]);





