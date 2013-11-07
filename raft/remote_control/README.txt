This directory contains the code for remote control of a raft.

0. OVERVIEW
Remote control of the rafts works as follows: a Processing sketch reads data from an xbox wireless gamepad and, after some
simple conversions, sends it to the raft over xbee. The two sticks are used to control the four propeller pods (stick 1 controls
pods 1 and 2, stick 2 controls 3 and 4). code running on the arduino reads the incoming data from the xbee and updates the pwm
and direction outputs for each of the four motors.

1. VERSIONS

Within the Arduino and Processing directories you should find several different sketches - one per raft iteration:

Virgil I - Rebirth!

The old raft, reborn.

Processing: This features control of the 4 propeller pods using the 2 thumbsticks on the XBox360 controller: left thumbstick controls pods 1+2
while the right controls 
Arduino: 
----

Virgil II:

We've added a 20lbf trolling motor to Virgil I! This means another Pololu module to handle the trolling motor. We've also turned it into a tethered vehicle using an extension cord. For now the tether is only carrying power - Virgil II can draw up to 20A@12V - hand drill not included.

Processing: The triggers now control the trolling motor speed and direction. The data packet has been modified to carry speed and direction for the main thruster
Arduino: Arduino code modified to read & parse the longer data packet and control the additional thruster

----

Virgil III:

We've upgraded the main thruster to a 35lbf thruster harvested from an old kayak. This requires two H-bridges in parallel (or one full Pololu carrier module).

Processing:
Arduino:

----

Virgil IV:

Processing:
Arduino:

---- 

2. DEPENDENCIES
The processing sketch makes use of the procontroll library (http://creativecomputing.cc/p5libs/procontroll/) to interface with the gamepad.

3. EXECUTION
After uploading the arduino code to the raft, 

4. FUTURE FEATURES

5. BUGS, LIMITATIONS AND OTHER "FEATURES"
The Processing code is not guaranteed to run in Linux due to some apparent library conflicts (at least in Ubuntu
12.04.3) and lack of compatibility with the xbox gamepad. It also seems not to run on 64-bit versions of processing -- use the
32 bit version)

----
Pedro Vaz Teixeira (pvt@mit.edu), 2013