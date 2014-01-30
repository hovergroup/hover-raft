function [ t, force, torque ] = readFTDataLVM( filename )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    data = textread(filename,'','delimiter','\t','headerlines',22);
    
    force(:,1) = data(1:6:end,2);
    force(:,2) = data(2:6:end,2);
    force(:,3) = data(3:6:end,2);
    
    torque(:,1) = data(4:6:end,2);
    torque(:,2) = data(5:6:end,2);
    torque(:,3) = data(6:6:end,2);
    
    t = (0:0.01:(0.01*(size(torque,1)-1)))';
end

