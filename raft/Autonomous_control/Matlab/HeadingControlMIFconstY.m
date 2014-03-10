%compute thrust command for theta using LQG controller
%EWG 2014

function [control1, control2, control3, xest, utheta, loss, gsim, psisim] = HeadingControlMIFconstY(x1,xestin,uthetain,gsimin,psisimin)
%Define system model
%model parameters
a=1.4;
b=4;
Kmodel=50;

A = [0 1 0; 0 0 1; 0 -(a+b) -a*b];
B = [0 0 Kmodel*a*b]';
C = [1 0 0];
D = 0;
dt = 0.1;
sys = ss(A,B,C,D);
sysd = c2d(sys,dt);  % system in discrete-time form
[Ad,Bd,Cd,Dd] = ssdata(sysd);  % discrete-time state-space matrices

%Kalman Estimator parameters
Qn = 1;
Rn = 1;
Nn = 0;
 [kest,L,P] = kalman(sysd,Qn,Rn,Nn); %L is kalman gain
%[kest,L,P] = kalman(sys,Qn,Rn,Nn); %L is kalman gain

%LQR controller parameters
Q = 100*eye(3);
R = 1;
N = 0;
[K,S,e] = dlqr(Ad,Bd,Q,R,N); %K is controller gain
alpha = 0.;
h=10; %quantization bin size
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MIF Parameters
%Y converges to this steady state value
Y=[ 1.6122 -0.0535 0.0375; -0.0535 0.3596 0.2685; 0.0375 0.2685 0.4018];

gamma = (Y-Cd'*inv(Rn)*Cd)*Ad*inv(Y);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define input parameters
theta=x1(3)*180/pi;
    ymeas = h*floor(theta/h+0.5); %quantized measurement
    gsim = Cd'*inv(Rn)*ymeas+gamma*gsimin
    psisim = (Y-Cd'*inv(Rn)*Cd)*Bd*(-K)*xestin+gamma*psisimin
    
    if rand>alpha %packet received
        xest = inv(Y)*(gsim+psisim);  %update state estimate
        %xest = Ad*xestin+Bd*uthetain+L*(ymeas-Cd*xestin);  %update state estimate
        loss=NaN;      
    else %packet lost
        xest = Ad*xestin+Bd*uthetain;
        loss=0;
        %disp('Packet Fake Lost');
    end
    
    utheta = -K*xest; %compute control command, u, as percentage of max thrust

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define controller gains
offset = 50;
thetathrust = utheta*255; %convert control command to be sent to raft
thetathrust = round255(thetathrust,offset)+offset*sign(thetathrust); %account for deadband %pvt approves

control = [0 0 thetathrust];
control1 = control(1);
control2 = control(2);
control3 = control(3);