%compute thrust command for theta using LQG controller
%EWG 2014

function [control1, control2, control3, yout, uout, loss] = HeadingControlLZLH(x1,yin,uin,PacketLoss)
%define vector of random numbers for use in packet loss (so all systems use
%identical sequence of packet loss

%Define system model
%model parameters
% a=1.4;
% b=4;
% Kmodel=54;
% A = [0 1 0; 0 0 1; 0 -(a+b) -a*b];
% B = [0 0 Kmodel*a*b]';
% C = [1 0 0];
% D = 0;

a=1.4;
Kmodel=54*a; %Kmodel was 50*a
A = [0 1; 0 -a];
B = [0 Kmodel]';
C = [1 0];
D = 0;

dt = 0.12;
sys = ss(A,B,C,D);
sysd = c2d(sys,dt);  % system in discrete-time form
[Ad,Bd,Cd,Dd] = ssdata(sysd);  % discrete-time state-space matrices

%Kalman Estimator parameters
Qn = 1;
Rn = 1;
Nn = 0;
 [kest,L,P] = kalman(sysd,Qn,Rn,Nn); %L is kalman gain
% [kestc,Lc,Pc] = kalman(sys,Qn,Rn,Nn); %continuous time kalman gain

%LQR controller parameters
Q = 100*eye(size(A));
R = 1;
N = 0;
[K,S,e] = dlqr(Ad,Bd,Q,R,N); %K is controller gain
% [Kc,Sc,ec] = lqr(A,B,Q,R,N); %continuous time parameters
 alpha = 0.23;
 h=6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define input parameters
%sys1 = ss(Ad-Bd*K-L*Cd,L,-K,0,dt); %dt was 0.1
In = eye(size(Ad));
%sys1 = ss((In-L*Cd)*(Ad-Bd*K),L,-K*((In-L*Cd)*(Ad-Bd*K)),-K*L,dt); %dt was 0.1
sys1 = ss((In-L*Cd)*(Ad-Bd*K),L,-K*((In-L*Cd)*(Ad-Bd*K)),-K*L,dt); %dt was 0.1

Hd = tf(sys1);
[numd, dend] = tfdata(Hd,'v');

theta=x1(3)*180/pi;
    
    if PacketLoss>=alpha %packet received
        y = 0.96*h*floor(theta/h+0.5);  %update state estimate
        loss=NaN;      
    else %packet lost
        %y = 0; %LZ
        y=1.0*yin(1); %LH
        loss=0;
        %disp('Packet Fake Lost');
    end
    yout = [y yin(1) yin(2) yin(3)];
    %utheta = 1/dend(1)*(numd(1)*yout(1)+numd(2)*yout(2)+numd(3)*yout(3)+numd(4)*yout(4)-dend(2)*uin(1)-dend(3)*uin(2)-dend(4)*uin(3));
    utheta = 0.7*1/dend(1)*(numd(1)*yout(1)+numd(2)*yout(2)+numd(3)*yout(3)-dend(2)*uin(1)-dend(3)*uin(2));
    
    %utheta = 1/dend(1)*(numd*yout'-dend(2:end)*uin(2:end)');
    uout = [utheta uin(1) uin(2) uin(3)];
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%define controller gains
offset = 30;
thetathrust = utheta*255; %convert control command to be sent to raft
%thetathrust = round255(thetathrust,offset)+offset*sign(thetathrust); %account for deadband %pvt approves

control = [0 0 thetathrust];
control1 = control(1);
control2 = control(2);
control3 = control(3);
