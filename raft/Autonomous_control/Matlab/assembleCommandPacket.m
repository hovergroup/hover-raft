function [packet] = assembleCommandPacket(thrust, direction)
%assembleCommandPacket assemble the telecommand packet to control the raft
%
%   Pedro Vaz Teixeira

	packet = uint8(['<';'[';'(']);

	for i=1:5;
		packet = [packet, uint8(thrust(i)), uint8(direction(i))];
	end

	packet = [packet, uint8([')';']';'>'])];