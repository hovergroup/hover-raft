function [ thrust ] = headingControl( thetaDesired, theta, dt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    persistent intError;
    persistent oldError;
    
    if isempty(intError)
        intError = 0;
    end
    
    if isempty(oldError)
        oldError = 0;
    end

    Kp = 150;
    Kd = 0;
    Ki = 3;
        
    error = thetaDesired - theta;
    
    if error > pi
        error = error - 2*pi;
    elseif error < -pi
        error = error + 2*pi;
    end
    
    intError = intError + error;
    v = Kp * error + Kd * (error - oldError)/dt + Ki*intError;
   
    % anti-windup
    if (v > 1 || v < -1 )
       intError = intError - error;
       v = v/abs(v);
    end
    
    thrust = [v -v v -v];
    
    oldError = error;    
end

