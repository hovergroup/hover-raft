clear all

%% Connect to Arduino
ans='connecting to arduino...'
a = arduino('/dev/ttyACM0','uno');
ans='connected!'

tic

while toc < 1000
    disp(readVoltage(a,0))
    pause(0.01)
end