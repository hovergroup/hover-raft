function [h] = initRealTimePlot
% initializes position and axes of realtime plot for tank cam
% also sets size and position on screen
% inputs:
% none
% outputs:
% h: figure handle

% note - was designed for faster runtime, but 'new' version of realtime
% plot fcn requires setting axes each time anyway due to hold on/off
% still save time by not setting position each step

% BR 11/10/2010 
% changelog:
%{
- author, date: change
- BR 3/3/2011 changed title to reflect init without update
    removed xRes,yRes input as well as axis setup (handled by actual plot
    updates if they are happening)
-
-
%}

h=888;
figure(h);

% NOTE - title shown only when not actually updated (reminder about ESC)
title({'PRESS ESC TO TERMINATE!!!';'NOT CURRENTLY UPDATING TRACKING'})

set(888,'Position',[150 420 400 450]);