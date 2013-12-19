function [thrust, direction] = mapToThruster(controlInput)
%mapToThruster map control signals to individual raft thrusters
%   The purpose of this function is to hide the implementation
%		details from the actual controller
%
%   Pedro Vaz Teixeira

	thrust = zeros(5,1);
	direction = zeros(5,1);

	orientation = [1 -1 1 -1 1];
	deadband = [35 35 35 35 25];
	for i=1:5;	
		thrust = abs(controlInput(i)) * (255 - deadband(i)) + deadband(i);
		direction = 2 + sign(controlInput(i));
	end
