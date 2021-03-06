function [thrust, direction] = mapToThruster(thrustX, thrustY, omega, currentHeading)
%mapToThruster map control signals to individual raft thrusters
%   The purpose of this function is to hide the implementation details from
%   the actual controller. It should take the desired thrust in X and Y,
%   and the desired angular velocity, and map it to the correct thrusters.
%
%   Pedro Vaz Teixeira


%{
X IS FORWARD
Y IS STARBOARD
Z IS UP
Thrusters:
#   POSITION    ORIENTATION     ROTATION
1   FORWARD     +Y              >0 (CCW)
2   STARBOARD   -X              <0 (CW)
3   AFT         -Y              >0 (CCW)
4   PORT        +X              <0 (CW)
%}
	thrust = zeros(5,1);
    direction = zeros(5,1);
   
    tx = cos(currentHeading)*thrustX - sin(currentHeading)*thrustY;
    ty = sin(currentHeading)*thrustX + cos(currentHeading)*thrustY;
    thrust(1) = 0.33*(ty + omega);
    thrust(2) = -tx - omega;
    thrust(3) = -ty + omega;
    thrust(4) = tx - omega;
    
    for i=1:4
        if thrust(i)>0
            thrust(i) = abs(min(thrust(i),255));
            direction(i) = 3;
        else
            thrust(i) = abs(max(thrust(i),-255));
            direction(i) = 1;
        end 
        
        if thrust(i) < 40
            thrust(i)  = 40;
        end
        
    end
