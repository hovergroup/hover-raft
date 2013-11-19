%function [data] = cameraTrackInput(trackIn,numBlobs,trackID)
function [data] = cameraTrackInput(trackIn,numBlobs)

% Read particle position packet(s) from SwisTrack TCP/IP input
% can change total number of packets and number of lines per packet
% inputs:
% trackIn: TCP/IP object for SwisTrack comms
% numBlobs: number of objects being tracked
% trackID: if SwisTrack is using markers and outputting IDs
% outputs:
% data is a cell: numLines x numPackets 
%   currently, numPackets is set to 1 in script, but can be modified
%
% implementation notes:
% this fcn first flushes buffer then reads next packet
% if speed (vs data delay) is preferred, could grab whole buffer and work
% backwards...

% can set so runs as script, and so that data printed to screen for debug

%  - BR 6/8/2011 - NEED TO DO 
%       - add timeout on wrong number of lines in packet?  
%       - so can re-check stopflag in main loop...

% BR 11/10/2010 
% changelog:
%{
- author, date: change
- BR 2/17/2011 - added check to see if correct number of lines in packet
               - currently keeps trying until gets full packet
               - could implement different error later if want to keep rest
                 of code running...
- BR 4/7/2011 - added trackID input - don't break if wrong # lines
-
%}

% if run as script
script=0;
% if print to screen
debug=1;

% if run as script:
if(script)
    clear all;close all;clc;
    format compact;
    trackIn=tcpip('localhost',3000);
    fopen(trackIn);
end

if(debug);inputStart=tic;end

numPackets=1;                       % number of packets to store
numLines=numBlobs+1;                % lines in one packet
data=cell(numLines,numPackets);

% init aux variables
packets=0;
endPacket=0;
foundStart=0;
line=1;

while(packets<numPackets)
    
    % full flush :
    while(get(trackIn,'BytesAvailable')>0)
        if(debug);fprintf('%g\n',trackIn.BytesAvailable);end
        [~]=fread(trackIn,trackIn.BytesAvailable);
        if(debug);fprintf('%g\n',trackIn.BytesAvailable);end
    end
    if(debug);fprintf('cleared \n');end
    
    waste=0;
    % check for start:
    while(foundStart==0)
        while(get(trackIn,'BytesAvailable')>0)
            checkStart=fgets(trackIn);
            % STEP_STOP is shortest line - check 1st 10 chars
            % if(strcmp(checkStart(1:10),'$STEP_STAR'))
            if(strcmp(checkStart(1:6),'$FRAME'))
                if(debug);fprintf('--------- NEW PACKET -----------\n');end
                foundStart=1;
                break
            end
            waste=waste+1;
            
        end
        %if(debug && foundStart==0);fprintf('\nwaste= %i',waste);end
    end
    foundStart=0;
    
    % keep trying until full packet
    while(endPacket==0)
        % listen for new bytes
        while (get(trackIn, 'BytesAvailable') > 0)
            % grab new line:
            % (use fgets if want to keep newline)
            % (use fgetl if want to discard newline)
            % (use fscanf if want to parse specific format)
            lineIn = fgetl(trackIn);
            % remove CR and LF at end:
            [~, b]=size(lineIn);
            % use b-2 if start with $STEP_START
            % use b-1 if start with $FRAME
            lineIn=lineIn(1:b-1);
            %store line in data cell:
            data{line,packets+1}=lineIn;
            line=line+1;
            if(debug);fprintf([lineIn,'\n']);end
            % check for end of packet:
            if(strcmp(lineIn(1:10),'$STEP_STOP'))
                packets=packets+1;
                endPacket=1;
                if(debug);
                    fprintf('--------- END OF PACKET %i -----------\n',...
                        packets);
                end
                % break out of this while loop:
                break
            end
        end
    end
    % after complete packet, reset indicator
    endPacket=0;
    
    % check to see if correct number of lines...
    if((line~=(numBlobs+2)))
        % if wrong number of lines, start over and try again
        
        % LATER - put in case for IDs - if use IDs, don't worry about
        % this...just read IDs
        
        %if(~trackID)
        
            packets=0;
            line=1;
            data=cell(numLines,numPackets);
        
        %end
        
        fprintf(' --- WRONG NUMBER OF LINES IN PACKET ---\n')
    end

end

if(debug);fprintf('time: %g\n',toc(inputStart));end

if(script)
    fclose(trackIn);
    delete(trackIn)
    clear trackIn
end