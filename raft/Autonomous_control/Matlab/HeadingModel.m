%Script to plot step responses of heading rate to thrust input, and derive
%transfer function model
%EWG Hovergroup 2013 
%egilbert@mit.edu
close all

count =10000;
theta0 = rad2deg(x(3,20));
headingvec = rad2deg(x(3,1:count))-theta0;

 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
 c = conv(headingvec,window,'same')/sum(window);
 
headingratevec = diff(c)./diff(t(1:size(c,2)));

% figure
% plot(t(1:count),headingvec,['-',color,'.'],'LineWidth',3);
% xlabel('Time [s]')
% ylabel('Heading [deg]');       
% grid on

figure
plot(t(20:size(c,2)-2),c(20:size(c,2)-2)+theta0,'-b.','LineWidth',3);
xlabel('Time [s]')
ylabel('Heading Smoothed [deg]');       
grid on
hold on
plot(t(20:count),headingvec(20:count)+theta0,['--','r','.'],'LineWidth',2);

figure
plot(t(20:size(headingratevec,2))-t(20),headingratevec(20:size(headingratevec,2)),'-b.','LineWidth',3);
xlabel('Time [s]')
ylabel('Heading Rate [deg]');       
grid on
% hold on
% plot(t(20:count),rad2deg(v5(3,20:count)),'-r.','LineWidth',3);
% xlabel('Time [s]')
% ylabel('Yaw rate [deg/s]');       
% grid on 

% figure
% plot(t(20:size(c,2)-1),diff(t(20:size(c,2))),['-',color,'.'],'LineWidth',3);
% xlabel('Time [s]')
% ylabel('Heading Rate [deg]');       
% grid on

figure
plot(t,uthetasave,'LineWidth',3);
xlabel('Time [s]')
ylabel('Control Command');       
grid on

figure
plot(t,xestsave(1,:),t,(headingvec+theta0),'LineWidth',3);
xlabel('Time [s]')
ylabel('Estimate-Meas [deg]');     
legend('Estimated \theta','Measured \theta')
grid on

figure
plot(t,xestsave(1,:)-(headingvec+theta0),'LineWidth',3);
xlabel('Time [s]')
ylabel('Estimate-Meas [deg]');     
%legend('Estimated \theta','Measured \theta')
grid on
