function control = raftcontrol(theta)

%Simple P controller for raft heading, for testing purposes
thetades=0;
Kp = 1;
thrustmax = 1.7;
thrust = -Kp*(theta-thetades);

%now convert thrust to m1d,m1s,m2d,...,m5s
m1d = 2+sign(thrust);
%m1s = floor(thrust/thrustmax*255);
m1s = 125;
m2d = 0;
m2s = 0;
m3d = 2+sign(-thrust);
m3s = m1s;
m4d = 0;
m4s = 0;
m5d = 0;
m5s = 0;

control = uint8(['<','<','<',m1d, m1s, m2d, m2s, m3d, m3s, m4d, m4s, m5d, m5s,'>','>','>']);






