function control = raftcontrolxy3(x1,vel,xdes1,IError)
%compute thrust commands for x, y, and theta and add them together
%EWG 2013
persistent ThetaError
if isempty(ThetaError)
    ThetaError = 0;
else
ThetaError = ThetaError + IError(3);
end

%anti windup
if ThetaError>50
    ThetaError = 50;
    disp('wind-up!');
elseif ThetaError<-50
    ThetaError = -50;
    disp('wind-up!');
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
Kitheta = 1;

offset = 30;

xthrust = -Kpx*(x-xdes)-Kdx*(xdot);
ythrust = -Kpy*(y-ydes)-Kdy*(ydot);
thetathrust = -Kptheta*(theta-thetades) - Kdtheta*thetadot - Kitheta*ThetaError;
disp(['p: ', num2str(Kptheta*(theta-thetades))])
disp(['i: ', num2str(Kitheta*ThetaError)])
disp(['d: ', num2str(Kdtheta*thetadot)]);
disp('---');
%offset from deadband and put in range -255 to 255
xthrust = round255(xthrust,offset)+offset*sign(xthrust);
ythrust = round255(ythrust,offset)+offset*sign(ythrust);
thetathrust = round255(thetathrust,offset)+offset*sign(thetathrust);

control = [xthrust ythrust thetathrust];
