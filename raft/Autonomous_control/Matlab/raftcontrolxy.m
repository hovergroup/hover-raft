function control = raftcontrolxy(theta,thetaOld,thetaDes,thetaError,IError,x,y,xdes1,ydes1,xold1,yold1)
%compute thrust commands for x, y, and theta and add them together
%EG

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%xy thrust commands

xdes = xdes1;
ydes = ydes1;
thetades=thetaDes;
offset = 30; %to account for motor not moving for commands less than offset
dt=0.1;

Kpx = 1;
Kpy = 5;

Kdy = 1;
Kdx = 5;

xthrust = -Kpx*(x-xdes)-Kdx*(x-xold1)/dt;
ythrust = -Kpy*(y-ydes)-Kdy*(y-yold1)/dt;
%see pg 77-78 of EG lab notebook #7 for derivation
M13 = -1/2*(xthrust-ythrust*tan(thetades))/(-cos(theta)-sin(theta)*tan(theta));
M24 = -1/2*(ythrust-M13*sin(theta))/cos(theta);

% M13a = round255(M13,offset);
% M24a = round255(M24,offset);
M13a = -xthrust;
M24a = -ythrust;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%heading control command calculation
Kp = 5; %was 5
Kd = 1; %was 1
Ki = 0;
dt = 0.1;

thrust = -Kp*(thetaError) - Kd*(theta - thetaOld)/dt - Ki*IError;
%now convert thrust to m1d,m1s,m2d,...,m5s
m1s = abs(M13a)+offset;
m1s = abs(round255(-thrust,offset))+offset;
m1d = 2+sign(thrust);
m2s = abs(M24a)+offset;
m2d = 2-sign(M24a);
m3s = abs(round255(-thrust,offset))+offset;
m3d = 2+sign(thrust);
m4s = m2s;
m4d = 2+sign(M24a);
m5s = 0;
m5d = 3;

% m1s = abs(round255(-xthrust,offset))+offset;
% m1d = 2+sign(thrust);
% m2s = abs(M24a)+offset;
% m2d = 2-sign(M24a);
% % m3s = m1s;
% m3s = abs(round255(-thrust,offset))+offset;
% m3d = 2+sign(thrust);
% m4s = m2s;
% m4d = 2+sign(M24a);
% m5s = 0;
% m5d = 3;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% %heading control command calculation
% Kp = 0; %was 5
% Kd = 0; %was 1
% Ki = 0;
% dt = 0.1;
% 
% thrust = -Kp*(thetaError) - Kd*(theta - thetaOld)/dt - Ki*IError;

%now convert thrust to m1d,m1s,m2d,...,m5s
% m1st = abs(thrust)+offset;
% %m1s = floor(thrust/thrustmax*255);
% m1dt = 2+sign(thrust);
% m2st = abs(thrust)+offset;
% m2dt = 2-sign(thrust);
% m3st = m2st;
% m3dt = 2+sign(thrust);
% m4st = m2st;
% m4dt = 2-sign(thrust);
% m5st = 0;
% m5dt = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%add the thrust commands together
% m1s = m1sxy;
% m1d = m1dxy;
% m2s = m2sxy;
% m2d = m2dxy;
% m3s = m3sxy;
% m3d = m3dxy;
% m4s = m4sxy;
% m4d = m4dxy;
% m5s = m5sxy;
% m5d = m5dxy;

% m1s = 0;
% m1d = 1;
% m2s = 0;
% m2d = 1;
% m3s = 0;
% m3d = 1;
% m4s = 0;
% m4d = 3;
% m5s = 0;
% m5d = 0;

% m1s = abs(round255(0.42*M13-thrust,offset))+offset;
% % m1s = 0;
% m1d = 2-sign(M13-thrust);
% m2s = abs(round255(-M24+thrust,offset))+offset;
% m2d = 2-sign(-M24+thrust);
% m3s = abs(round255(-M13-thrust,offset))+offset;
% % m3s = 0;
% m3d = 2+sign(M13+thrust);
% m4s = abs(round255(M24-thrust,offset))+offset;
% m4d = 2+sign(M24-thrust);
% m5s = 0;
% m5d = 0;
control = uint8(['<';'[';'(';m1s; m1d; m2s; m2d; m3s; m3d; m4s; m4d; m5s; m5d;')';']';'>']);
