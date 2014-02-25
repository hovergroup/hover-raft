function [ thrust ] = headingControl( thetaDesired, theta, dt )
%headingControl PID-based heading controller for the raft
%   PID-based heading controller for the raft
%
%   Eric Gilbertson
%   Pedro Vaz Teixeira

    persistent intError;
    persistent oldError;
    
    if isempty(intError)
        intError = 0;
    end
    
    if isempty(oldError)
        oldError = 0;
    end

    Kp = 5;
    Kd = 2;
    Ki = 10;
        
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
    offset = 30;
    %thrust = [v -v v -v];
    vrounded =round255(v,offset)+offset;
    
    thrust = [0 0 vrounded];
    oldError = error;    
end

