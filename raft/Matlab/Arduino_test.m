clear a
%% Connect to Arduino

disp('connecting to arduino...')
a = arduino('/dev/ttyACM0','uno');
disp('connected!')


tic

while toc < 10000
    disp(readVoltage(a,0))
    pause(0.01)
end