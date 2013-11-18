function realtimePlotCam(plotCase,h,ID,x,y,xRes,yRes,numBlobs)
% plots (x,y) positions of blobs in 1-225 tank in real-time (in pixels)
% uses camera coords aligned with tank
% inputs:
% plotCase: how plotting is done 
%   options='all','none','new'
%          'all' is slow, 'new' is preferred, 'none' is blank
% h: handle to figure (init in main script)
% ID, x, y: ID#s and positions (VECTORS) of blobs to be plotted
% xRes, yRes: camera resolution parameters
% numBlobs: number of Blobs to be plotted (should match size of ID vector)

% notes:
% currently colors for only 6 rafts...
% could add structure as input for better flexibility of what to plot

% BR,11/10/2010
% changelog:
%{
- author, date: change
- BR, 3/3/2011 - changed so doesn't check for stopflag here...in main loop
-
-
%}


figure(h)

%colorlist={'b','r','k','g','m','c'};
% match matlab:
c=[0 .75 .75];
g=[0 0.5 0];
m=[0.75 0 0.75];
colorlist={'b',g,'r',c,m,'k'};

switch plotCase
% plots all values (always hold on)
% plotting (and thus overall loop) gets slower with time...
    case 'all'      
        plot(-y,x,colorlist{ID});
        hold on
        drawnow
% plot nothing (still keep figure up to catch ESC => stopflag)
    case 'none'
        %nothing
% plots newest updates (holds one set of vehicle positions)
    case 'new'
        plot(-y,x,'d','MarkerSize',10,'MarkerFaceColor',...
            colorlist{ID});
        axis equal
        axis([-yRes 0 0 xRes]);
        grid on
        title({'PRESS ESC TO TERMINATE!!!';'Camera Tracking'})
        ylabel('x (window edge) [pixels]')
        xlabel('-y (away from window) [pixels]')
        if(ID==numBlobs)
            hold off
        else 
            hold on
        end
        drawnow
end
