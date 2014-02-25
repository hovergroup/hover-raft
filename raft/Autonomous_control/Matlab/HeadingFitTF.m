%function to fit model to heading rate data

close all
%Load Data from Tests
count = 100;
%--------
load('./data/HeadingTestThrust250.mat')
theta0 = rad2deg(x(3,20));
headingvec = rad2deg(x(3,1:count))-theta0;
 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
 c = conv(headingvec,window,'same')/sum(window); 
headingratevec250 = diff(c)./diff(t(1:size(c,2)));
tvec250 = t(20:60)-t(20);
%--------
load('./data/HeadingTestThrust200.mat')
theta0 = rad2deg(x(3,20));
headingvec = rad2deg(x(3,1:count))-theta0;
 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
 c = conv(headingvec,window,'same')/sum(window); 
headingratevec200 = diff(c)./diff(t(1:size(c,2)));
tvec200 = t(20:60)-t(20);
%--------
load('./data/HeadingTestThrust150.mat')
theta0 = rad2deg(x(3,20));
headingvec = rad2deg(x(3,1:count))-theta0;
 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
 c = conv(headingvec,window,'same')/sum(window); 
headingratevec150 = diff(c)./diff(t(1:size(c,2)));
tvec150 = t(20:60)-t(20);
%--------
load('./data/HeadingTestThrust100.mat')
theta0 = rad2deg(x(3,20));
headingvec = rad2deg(x(3,1:count))-theta0;
 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
 c = conv(headingvec,window,'same')/sum(window); 
headingratevec100 = diff(c)./diff(t(1:size(c,2)));
tvec100 = t(20:60)-t(20);
%--------
%Calculate Model
s=tf([1 0],1);
%second-order system
a=1.4;
b=4;
K = 50*a*b;
sys = K/((s+a)*(s+b));
[ys,ts] = step(sys,4);

%first order system
% a=1;
% K=50*a;
% sys = K/(s+a);
% [ys,ts] = step(sys,4);

figure
plot(tvec250,headingratevec250(20:60),'--k.',ts,ys,'-r',tvec200,headingratevec200(20:60),'--g.',tvec150,headingratevec150(20:60)+1,'--b.',tvec100,headingratevec100(20:60)+1,'--m.','LineWidth',3);
xlabel('Time [s]','FontSize',16)
ylabel('Heading Rate [deg/sec]','FontSize',16);
set(gca,'FontSize',16)
axis([0 4 0 55]);
h0=legend('Heading Rate Data','Model');
rect = [0.65, 0.27, 0.05, 0.05];
set(h0,'Position',rect);
grid on
hold on
plot(ts,ys*0.8,'-r',ts,ys*0.6,'-r',ts,ys*0.4,'-r','LineWidth',3)

print(gcf, '-depsc','RaftModel1')
print(gcf, '-dpng','RaftModel1')
print(gcf, '-djpeg','RaftModel1')