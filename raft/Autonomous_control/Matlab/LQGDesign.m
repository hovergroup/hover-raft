%design LQG controller/estimator for raft heading control
clear all
close all
clc

%Define system model
A = [0 1 0; 0 0 1; 0 -5.6 -5.4];
B = [0 0 280]';
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
%[K,S,e] = lqr(A,B,Q,R,N); %K is controller gain
%Simulate System
simnum = 100000;
xact=zeros(3,simnum); %actual plant state
xest = zeros(3,simnum); %estimated plant state
y=zeros(1,simnum);
u = zeros(1,simnum);
y(1,1)=20;
x(:,1) = [20 0 0]';
time = 1:1:simnum;
h=20; %quantization bin size

alpha = 0.8; %packet loss probability

for i=1:simnum-2
    xact(:,i+1) = Ad*xact(:,i) + Bd*u(i)+[1 1 1]'*sqrt(10*Qn)*(2*rand-1); %propagate actual plant state
    y(i+1)=h*floor(Cd*xact(:,i+1)/h+0.5)+sqrt(Rn)*(2*rand-1); %take quantized measurement, add 0.5 to center it
    
    if rand>alpha %packet received
        xest(:,i+1) = Ad*xest(:,i)+Bd*u(i)+L*(y(i)-Cd*xest(:,i));  %update state estimate
    else %packet lost
        xest(:,i+1) = Ad*xest(:,i)+Bd*u(i);
    end
    
    u(i+1) = -K*xest(:,i+1); %compute control command
end

figure
plot(dt*time,xact(1,:))
xlabel('Time (sec)')
ylabel('Heading (deg)')
