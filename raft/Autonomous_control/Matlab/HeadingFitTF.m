%function to fit model to heading rate data

 close all
%Load Data from Tests
count = 100;
start = 20;
tend = 35;
%%
%load('C:\Users\bubba\Dropbox\data\HeadingTestThrust250.mat')
%load('C:\Users\bubba\Dropbox\data\HeadingTestDeadbandThrust255.mat')
load('C:\Users\bubba\Dropbox\data\HeadingTestMarch26_255a.mat')
theta0 = rad2deg(x(3,start));
headingvec250 = rad2deg(x(3,1:count))-theta0;
 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
c = conv(headingvec250,window,'same')/sum(window); 
 %c=headingvec250;
headingratevec250 = diff(c)./diff(t(1:size(c,2)));
tvec250 = t(start:tend)-t(start);
%%
%load('C:\Users\bubba\Dropbox\data\HeadingTestThrust200.mat')
%load('C:\Users\bubba\Dropbox\data\HeadingTestDeadbandThrust200c.mat')
load('C:\Users\bubba\Dropbox\data\HeadingTestMarch26_200a.mat')
theta0 = rad2deg(x(3,start));
headingvec200 = rad2deg(x(3,1:count))-theta0;
 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
c = conv(headingvec200,window,'same')/sum(window); 
 %c=headingvec200;
headingratevec200 = diff(c)./diff(t(1:size(c,2)));
tvec200 = t(start:tend)-t(start);
%%
%load('C:\Users\bubba\Dropbox\data\HeadingTestThrust150.mat')
%load('C:\Users\bubba\Dropbox\data\HeadingTestDeadbandThrust150c.mat')
load('C:\Users\bubba\Dropbox\data\HeadingTestMarch26_150a.mat')
theta0 = rad2deg(x(3,start));
headingvec150 = rad2deg(x(3,1:count))-theta0;
 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
c = conv(headingvec150,window,'same')/sum(window); 
% c=headingvec150;
 headingratevec150 = diff(c)./diff(t(1:size(c,2)));
tvec150 = t(start:tend)-t(start);
%%
%load('C:\Users\bubba\Dropbox\data\HeadingTestThrust100.mat')
%load('C:\Users\bubba\Dropbox\data\HeadingTestDeadbandThrust100.mat')
load('C:\Users\bubba\Dropbox\data\HeadingTestMarch26_100a.mat')
theta0 = rad2deg(x(3,start));
headingvec100 = rad2deg(x(3,1:count))-theta0;
 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
c = conv(headingvec100,window,'same')/sum(window); 
%c=headingvec100;
headingratevec100 = diff(c)./diff(t(1:size(c,2)));
tvec100 = t(start:tend)-t(start);
%%
load('C:\Users\bubba\Dropbox\data\HeadingTestMarch26_50a.mat')
theta0 = rad2deg(x(3,start));
headingvec50 = rad2deg(x(3,1:count))-theta0;
 window = [sin(pi/6) sin(pi/3), sin(pi/2) sin(pi/3) sin(pi/6)];
c = conv(headingvec50,window,'same')/sum(window); 
%c=headingvec50;
 headingratevec50 = diff(c)./diff(t(1:size(c,2)));
tvec50 = t(start:tend)-t(start);
%%
dt=0.12;
%Calculate Model
%use fminsearch to find optimal coefficients
 weights = [1 1 4000 4000 5000];
% costfun = @(z)sum(weights(1)*(Stepmags2(z,start,tend)-headingratevec250(start:tend)).^2+weights(2)*(230/255*Stepmags2(z,start,tend)-headingratevec200(start:tend)).^2+weights(3)*(180/255*Stepmags2(z,start,tend)-headingratevec150(start:tend)).^2+weights(4)*(130/255*Stepmags2(z,start,tend)-headingratevec100(start:tend)).^2+weights(5)*(80/255*Stepmags2(z,start,tend)-headingratevec50(start:tend)).^2);
% costfun = @(z)sum(weights(1)*(Stepmags2h(z,start,tend)-headingvec250(start:tend)).^2+weights(2)*(230/255*Stepmags2h(z,start,tend)-headingvec200(start:tend)).^2+weights(3)*(180/255*Stepmags2h(z,start,tend)-headingvec150(start:tend)).^2+weights(4)*(130/255*Stepmags2h(z,start,tend)-headingvec100(start:tend)).^2+weights(5)*(80/255*Stepmags2h(z,start,tend)-headingvec50(start:tend)).^2); 
% xopt = fminsearch(costfun,[1.4, 4, 58*1.4*4]);
% a = xopt(1);
% b = xopt(2);
% K = xopt(3);
%second-order system
% a=1.4;
% b=5;
% K = 58*a*b;

% s=tf([1 0],1);
% sys = K/((s+a)*(s+b));
% syshead = sys/s;
% [ys,ts] = step(sys,4);
% [ysh,tsh] = step(syshead,4);

%first order system with delay
% dt=0.12;
% costfun = @(z)sum(weights(1)*(Stepmags1h(z,start,tend)-headingvec250(start:tend)).^2+weights(2)*(230/255*Stepmags1h(z,start,tend)-headingvec200(start:tend)).^2+weights(3)*(180/255*Stepmags1h(z,start,tend)-headingvec150(start:tend)).^2+weights(4)*(130/255*Stepmags1h(z,start,tend)-headingvec100(start:tend)).^2+weights(5)*(80/255*Stepmags1h(z,start,tend)-headingvec50(start:tend)).^2); 
% xopt = fminsearch(costfun,[1.4, 80]);
a = 2.0905;
K = 99.7466;
% a=xopt(1);
% K=xopt(2);
T = 3*dt;
 s=tf([1 0],1);
sys = K/(s+a)*exp(-s*T);
syshead = sys/s;
[ys,ts] = step(sys,4);
[ysh,tsh] = step(syshead,4);

% figure
% plot(tvec250,headingratevec250(start:tend),'--k.',ts,ys,'-r',tvec200,headingratevec200(start:tend),'--g.',tvec150,headingratevec150(start:tend),'--b.',tvec100,headingratevec100(start:tend),'--m.',tvec50,headingratevec50(start:tend),'--c.','LineWidth',3);
% xlabel('Time [s]','FontSize',16)
% ylabel('Heading Rate [deg/sec]','FontSize',16);
% set(gca,'FontSize',16)
% axis([0 dt*(tend-start) 0 40]);
% h0=legend('Heading Rate Data','Model');
% rect = [0.65, 0.17, 0.05, 0.05];
% set(h0,'Position',rect);
% grid on
% hold on
% plot(ts,ys*230/255,'-r',ts,ys*180/255,'-r',ts,ys*130/255,'-r',ts,ys*80/255,'-r','LineWidth',3)

% print(gcf, '-depsc','RaftModel7')
% print(gcf, '-dpng','RaftModel7')
% print(gcf, '-djpeg','RaftModel7')

%-----------------------------------------------
figure
%plot(tvec250,headingvec250(start:tend),'--k.',tsh,ysh,'-r',tvec200,headingvec200(start:tend),'--g.',tvec150,headingvec150(start:tend),'--b.',tvec100,headingvec100(start:tend),'--m.',tvec50,headingvec50(start:tend),'--c.','LineWidth',3);
plot(tvec200,headingvec200(start:tend),'--k.',tsh,ysh*230/255,'-r',tvec150,headingvec150(start:tend),'--b.',tvec100,headingvec100(start:tend),'--m.',tvec50,headingvec50(start:tend),'--c.','LineWidth',3);
xlabel('Time [s]','FontSize',16)
ylabel('Heading [deg]','FontSize',16);
set(gca,'FontSize',16)
axis([0 1 0 15]);
h0=legend('Heading Data','Model');
rect = [0.45, 0.6, 0.05, 0.05];
set(h0,'Position',rect);
grid on
hold on
plot(tsh,ysh*180/255,'-r',tsh,ysh*130/255,'-r',tsh,ysh*80/255,'-r','LineWidth',3)
print(gcf, '-depsc','RaftModel8')
print(gcf, '-dpng','RaftModel8')
print(gcf, '-djpeg','RaftModel8')
%--------------------------------------------------

% 
% K=220;
% a=2;
% 
% sysh100 = K/(s^2+a*s)*8/(3*pi)*1/(s+8/(3*pi)*1);
% [y100,t100] = step(sysh100,4);
% sysh90 = K/(s^2+a*s)*8/(3*pi)*0.9^2/(s+8/(3*pi)*0.9^2);
% [y90,t90] = step(sysh90,4);
% sysh70 = K/(s^2+a*s)*8/(3*pi)*0.7^2/(s+8/(3*pi)*0.7^2);
% [y70,t70] = step(sysh70,4);
% sysh50 = K/(s^2+a*s)*8/(3*pi)*0.5^2/(s+8/(3*pi)*0.5^2);
% [y50,t50] = step(sysh50,4);
% sysh30 = K/(s^2+a*s)*8/(3*pi)*0.3^2/(s+8/(3*pi)*0.3^2);
% [y30,t30] = step(sysh30,4);
% 
% figure
% plot(tvec250,headingvec250(start:tend),'--k.',t100,y100,'-r',tvec200,headingvec200(start:tend),'--g.',tvec150,headingvec150(start:tend),'--b.',tvec100,headingvec100(start:tend),'--m.',tvec50,headingvec50(start:tend),'--c.','LineWidth',3);
% xlabel('Time [s]','FontSize',16)
% ylabel('Heading [deg]','FontSize',16);
% set(gca,'FontSize',16)
% axis([0 dt*(tend-start) 0 20]);
% h0=legend('Heading Rate Data','Model');
% rect = [0.65, 0.17, 0.05, 0.05];
% set(h0,'Position',rect);
% grid on
% hold on
% plot(t90,y90,'-r',t70,y70,'-r',t50,y50,'-r',t30,y30,'-r','LineWidth',3)




