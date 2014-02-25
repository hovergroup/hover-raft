%script to output constant heading thrust, with no thrust output for first few
%seconds

function thrust = ConstThrust(count)

if count<20
    thrust = [0 0 0];
else
    thrust = [0 0 100];
end
