%script to output constant heading thrust, with no thrust output for first few
%seconds

function thrust = ConstThrust(count)

utheta = 255/255;

offset = 30;
thetathrust = utheta*255; %convert control command to be sent to raft
thetathrust = round255(thetathrust,offset)+offset*sign(thetathrust); %account for deadband %pvt approves

if count<20
    thrust = [0 0 0];
else
    thrust = [0 0 thetathrust];
end