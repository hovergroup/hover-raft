function control = raftcontrolxy3(x1,vel,xdes1,IError)
%compute thrust commands for x, y, and theta and add them together
%EG
persistent ThetaError
if isempty(ThetaError)
    ThetaError = 0;
else
ThetaError = ThetaError + IError(1);
end

%anti windup
if ThetaError>3
    ThetaError = 3;
elseif ThetaError<-3
    ThetaError = -3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define input parameters
xdes = xdes1(1);
ydes = xdes1(2);
thetades=xdes1(3)*180/pi;
x=x1(1);
y=x1(2);
theta=x1(3)*180/pi;
xdot = vel(1);
ydot = vel(2);
thetadot = vel(3)*180/pi;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define controller gains, independent PID controllers for x,y,theta
Kpx = 5;
Kpy = 5;
Kptheta = 5;

Kdy = 2;
Kdx = 2;
Kdtheta = 2;

Kiy = 0;
Kix = 0;
Kitheta = 10;

offset = 30;

xthrust = -Kpx*(x-xdes)-Kdx*(xdot);
ythrust = -Kpy*(y-ydes)-Kdy*(ydot);
thetathrust = -Kptheta*(theta-thetades) - Kdtheta*thetadot - Kitheta*ThetaError;

%offset from deadband and put in range -255 to 255
xthrust = round255(xthrust,offset)+offset;
ythrust = round255(ythrust,offset)+offset;
thetathrust = round255(thetathrust,offset)+offset;

control = [xthrust ythrust thetathrust];
