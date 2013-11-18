function [measOUT] = parseTrack(stringIn,xRes,yRes)
% Parse SwisTrack output string into variables and xforms coords
% inputs:
% string: string of data (one line from packet)
% xRes,yRes: camera resolutions
% outputs:
% measOut: vector [x,xdot,y,ydot,theta,ID]
% theta in DEG, zero aligned w/ tank, but compass signs (direction)
% 
% uses xRes and yRes to perform coordinate xform (mirror and rotate)
% due to SwisTrack output 

% BR 11/10/10
% changelog:
%{
- author, date: change
- BR 2/15/2011 - added xRes and yRes input, plus ST to tank coord xform
- BR 2/17/2011 - changed output to measOUT vector 
- BR 3/29/2011 - changed input name to stringIn to avoid overloading string
- BR, 4/4/2011 - changed theta to log in deg, and direction to match 
    compass sign convention ( (-) of swistrack)
-
%}


% string format:
% $PARTICLE,-1,399.612,226.015,-1.35731,1.73713e-039,8.96831e-043*0D

data=textscan(stringIn,'%9s %f %f %f %f %f %f','delimiter',',');
ID=data{2};
xST=data{3};
yST=data{4};
theta=data{5};
xdot=data{6};
ydot=data{7};

% xform SwisTrack output to tank coords:
y=-yST+yRes;
x=-xST+xRes;
theta=-theta*(180/pi);

measOUT=[x,xdot,y,ydot,theta,ID];

end