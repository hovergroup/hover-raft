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
	thrust = zeros(4,1);
    direction = zeros(4,1);
    
    thrust(1) = thrustX*sin(currentHeading) + thrustY*cos(currentHeading) + omega;
    thrust(2) = -1* (thrustX*cos(currentHeading) + thrustY*sin(currentHeading) + omega);
    thrust(3) = -1*(thrustX*sin(currentHeading) + thrustY*cos(currentHeading) + omega);
    thrust(4) = thrustX*cos(currentHeading) + thrustY*sin(currentHeading) + omega;
    
    for i=1:4
        if thrust(i)>0
            thrust(i) = min(thrust(i),255);
            direction(i) = 3;
        else
            thrust(i) = max(thrust(i),-255);
            direction(i) = 1;
        end 
    end
