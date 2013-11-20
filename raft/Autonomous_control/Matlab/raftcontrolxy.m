function control = raftcontrolxy(theta,x,y)

%Simple P controller for raft xy, for testing purposes
xdes = 200;
ydes = 2000;
thetades=0;

Kp = 0.01;
Kpx =0.03;
Kpy = 0.03;

thrustmax = pi*Kp;
thrust_theta = -Kp*(theta-thetades);
xthrust = -Kpx*(x-xdes)
ythrust = -Kpy*(y-ydes)

M24 = (xthrust-ythrust*tan(theta))/(cos(theta)-sin(theta)*tan(theta))
M13 = (ythrust-M24*sin(theta))/cos(theta)

%now convert thrust to m1d,m1s,m2d,...,m5s
m1s = abs(1/2*M13);
m1d = 2+sign(M13);
m2s = abs(1/2*M24);
m2d = 2+sign(M24);
m3s = m1s;
m3d = 2+sign(-M13);
m4s = m2s;
m4d = 2+sign(-M24);
m5s = 0;
m5d = 3;

% m1s = 0;
% %m1s = floor(thrust/thrustmax*255);
% m1d = 1;
% m2s = 0;
% m2d = 3;
% m3s = 0;
% m3d = 1;
% m4s = 0;
% m4d = 3;
% m5s = 0;
% m5d = 3;

control = uint8(['<';'[';'(';m1s; m1d; m2s; m2d; m3s; m3d; m4s; m4d; m5s; m5d;')';']';'>']);