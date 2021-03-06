%compute thrust command for theta using LQG controller
%EWG 2014

function [control1, control2, control3, xest, utheta, loss] = HeadingControlLQG(x1,xestin,uthetain)
%Define system model
%model parameters
a=1.4;
b=4;
Kmodel=50;

% a=0.095;
% b=5;
% Kmodel=400;

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
Q = 10000*eye(3);
R = 1;
N = 0;
[K,S,e] = dlqr(Ad,Bd,Q,R,N); %K is controller gain
%K=2*K;
alpha = 0.0;
h=0.00001;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define input parameters
theta=x1(3)*180/pi;
    y = h*floor(theta/h+0.5); 
    
    if rand>alpha %packet received
        xest = Ad*xestin+Bd*uthetain+L*(y-Cd*xestin);  %update state estimate
        loss=NaN;      
    else %packet lost
        xest = Ad*xestin+Bd*uthetain;
        loss=0;
        %disp('Packet Fake Lost');
    end

    utheta = -K*xest; %compute control command, u, as percentage of max thrust

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define controller gains
offset = 30;
thetathrust = utheta*255; %convert control command to be sent to raft
thetathrust = round255(thetathrust,offset)+offset*sign(thetathrust); %account for deadband %pvt approves

control = [0 0 thetathrust];
control1 = control(1);
control2 = control(2);
control3 = control(3);
