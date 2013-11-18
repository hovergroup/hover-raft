function [fid filename] = constructFile(prefix)
% Creates and opens a new file with the date and time as the name
% File created is a text file, new data appended if file already exists
% inputs:
% prefix: string to add in front of date and time (use '' for nothing)
% outputs:
% fid: file handle
% filename: string filename (without .txt)

% BR 8/25/2010
% changelog:
%{
- author, date: change
-
-
-
%}

% construct filename from data and time
today=date;
clockvec=clock;
hour=clockvec(4);
min=clockvec(5);
sec=round(clockvec(6));
filename=sprintf('%s%s-%d-%d-%d',prefix,today,hour,min,sec);
%filename=sprintf('%s%s-%d-%d',prefix,today,hour,min);
% create text file for logging data
fid=fopen([filename,'.txt'],'a+');