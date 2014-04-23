%Script to plot step responses of heading rate to thrust input, and derive
%transfer function model
%EWG Hovergroup 2014 
%egilbert@mit.edu
close all
%load('C:\Users\bubba\Dropbox\data\TestsStartingApril2\QLHtesth6alpha55_test1.mat')
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
count =470;
start =342;
figure
stairs(t(start:count)-t(start),(headingvec(start:count)+theta0),['-','b','.'],'LineWidth',2);
% hold on
% u = zeros(size(t(start:count)));
% v = ones(size(t(start:count)));
% quiver(t(start:count)-t(start),lossvec(start:count),u,v,0.05,'r', 'ShowArrowHead','off');
% quiver(t(start:count)-t(start),lossvec(start:count),u,-v,0.05,'r','ShowArrowHead','off');

%hold on 
%plot(t(start:count),0*t(start:count)+7.5,'r',t(start:count),0*t(start:count)-7.5,'r')
% hold on
% stairs(t(20:count),uthetasave(20:count),'r','LineWidth',2)
%plot(t(20:count),0*t(20:count)+5,'r',t(20:count),0*t(20:count)-5,'r')
%plot(t(1:size(c,2)-2),c(1:size(c,2)-2)+theta0,'-b.','LineWidth',3);
xlabel('Time [s]','FontSize',16)
ylabel('Heading [deg]','FontSize',16);
%title('Q, h=10','FontSize',16)
set(gca,'FontSize',16)
%legend('Heading','Control Command')
axis([0 15 -35 9.9]);
grid on
% 
print(gcf, '-depsc','StepNoLoss1Delay1')
print(gcf, '-dpng','StepNoLoss1Delay1')
print(gcf, '-djpeg','StepNoLoss1Delay1')

break

figure
plot(t(1:size(headingratevec,2)),headingratevec(1:size(headingratevec,2)),'-b.',t,xestsave(2,:),'-g.','LineWidth',3);
xlabel('Time [s]')
ylabel('Heading Rate [deg]'); 
legend('Meas','Est')
grid on
% hold on
% plot(t,xestsave(2,:),'LineWidth',3);
% xlabel('Time [s]')
% ylabel('Yaw rate [deg/s]');       
% grid on 

figure
plot(t(20:size(c,2)-1),diff(t(20:size(c,2))),['-',color,'.'],'LineWidth',3);
xlabel('Time [s]')
ylabel('dt');       
grid on

figure
plot(t(20:count),uthetasave(20:count),'LineWidth',3);
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
