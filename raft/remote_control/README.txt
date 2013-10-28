This directory contains the code for remote control of a raft.

1. OVERVIEW
Remote control of the rafts works as follows: a Processing sketch reads data from an xbox wireless gamepad and, after some
simple conversions, sends it to the raft over xbee. The two sticks are used to control the four propeller pods (stick 1 controls
pods 1 and 2, stick 2 controls 3 and 4). code running on the arduino reads the incoming data from the xbee and updates the pwm
and direction outputs for each of the four motors.

2. DEPENDENCIES
The processing sketch makes use of the procontroll library (http://creativecomputing.cc/p5libs/procontroll/) to interface with
the gamepad.

3. Processing 

4. Arduino  


5. BUGS, LIMITATIONS AND OTHER "FEATURES"
The Processing code is not guaranteed to run in Linux due to some apparent library conflicts (at least in Ubuntu
12.04.3) and compatibility with the xbox gamepad.

----
Pedro Vaz Teixeira (pvt@mit.edu), 2013