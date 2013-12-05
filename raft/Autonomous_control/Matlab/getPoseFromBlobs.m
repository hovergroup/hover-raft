function [ pose ] = getPoseFromBlobs( xMeas )
%UNTITLED Summary of this function goes here
%   This function takes the swistrack output (x, y, xdot, ydot, theta for
%   each blob) and computes the pose vector (x, y, theta) for the raft
%
%   EG

	% first compute position and heading of raft  
    % a,b,d are side lengths, A,B,D are points
    a = sqrt((xMeas(3,2)-xMeas(3,1))^2+(xMeas(1,2)-xMeas(1,1))^2);
    b = sqrt((xMeas(3,2)-xMeas(3,3))^2+(xMeas(1,2)-xMeas(1,3))^2);
    d = sqrt((xMeas(3,3)-xMeas(3,1))^2+(xMeas(1,3)-xMeas(1,1))^2);
   
    switch max(a,max(b,d));
        case a
            A = [xMeas(1,3), xMeas(3,3)];
        case b
            A = [xMeas(1,1), xMeas(3,1)];
        case d
            A = [xMeas(1,2), xMeas(3,2)];
   end
   
   switch min(a,min(b,d));
       case a
           D = [xMeas(1,3), xMeas(3,3)];
       case b
           D = [xMeas(1,1), xMeas(3,1)];
       case d
           D = [xMeas(1,2), xMeas(3,2)];
   end   

   theta = atan2((D(2)-A(2)),(D(1)-A(1)));
       
   x = 1/2*(A(1)+D(1));
   y = 1/2*(A(2)+D(2));
    
   pose = [x y theta];
end

