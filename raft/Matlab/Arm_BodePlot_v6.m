clear all

%% Create Bode Plot of Arm's Velocity Response

% Initialize MOOS

% Define the frequency range to test the arm
%omega = 10.^(0.1:0.01:1.1);
omega = 10.^0.1;

mag  = zeros(1,1);
phase = zeros(1,1);
phase_lag = zeros(1,1);
amplitude_ratio = zeros(1,1);
zeroed  = zeros(1,1);
pot2pos = -1.096*10^4;


disp('connecting to arduino...')
a = arduino('/dev/ttyACM0','uno');
disp('connected!')

for j=1:length(omega)
    
    % Zero arm position
    mexmoos('CLOSE');
    pause(1);
    mexmoos('init','SERVERHOST','localhost','SERVERPORT','9000');
    pause(1);
    
    msgs=mexmoos('FETCH');
    
    while (zeroed==0)
        if (readVoltage(a,0) < 2.5)
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',-50);
        elseif (readVoltage(a,0) > 2.5)
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',50);
        else
            zeroed=1;
            disp('Zeroed!')
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',0);
            mexmoos('CLOSE');
            pause(1);
            mexmoos('init','SERVERHOST','localhost','SERVERPORT','9000');
            pause(1);
            mexmoos('REGISTER','ECA_SHOULDER_SPEED',0);
            mexmoos('REGISTER','ECA_SHOULDER_POSITION',0);
            tic;
        end
    end
   
    time = zeros(1,1);
    speed = zeros(1,1);
    position = zeros(1,1);
    command = zeros(1,1);
    pottime = zeros(1,1);
    av = zeros(1,1);

    speed_index = 1;
    position_index = 1;
    pot_index = 1;
    exit = 0;
    tic;
    while (exit==0)
        msgs=mexmoos('FETCH');

        if (toc < 0.825)
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',0);
            cmd = 0;
        end
        if (toc > 0.825)
            av(pot_index)=readVoltage(a,0);
            pottime(pot_index)=toc;
            pot_index=pot_index+1;
            
            cmd = cos((toc-1)*omega(j))*100;
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',cmd);
        end
            
        if (~isempty(msgs))
            for k=1:length(msgs)
                if(strcmp(msgs(k).KEY,'ECA_SHOULDER_SPEED'))
                    speed(speed_index)=msgs(k).DBL;
                    time(speed_index) = toc;
                    command(speed_index) = cmd;
                    speed_index = speed_index+1;
                elseif(strcmp(msgs(k).KEY,'ECA_SHOULDER_POSITION'))
                    position(position_index)=msgs(k).DBL;
                    position_index = position_index+1;
                end
            end
        end

        if (abs(position_index-speed_index)>1)
            fprintf('error indices separated')
            exit = 1;
        end

        if (toc > 10*2*pi/omega(j)+1.175)
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',0);
            exit = 1;
        end
        
        pause(0.01);
    end


    mexmoos('CLOSE');

    close all;
    
    
    newpos = [];
    newvel = [];
    newtime = [];
    newcom = [];
    index = 1;
 
    currentpos = -8888888;
    currentvel = -8888888;
 
    for a=1:length(position)
        if position(a)~=currentpos
            currentpos=position(a);
            newcom(index)=command(a);
            newpos(index)=currentpos;
            newvel(index)=speed(a);
            newtime(index)=time(a);
            index=index+1;
        end
    end
    
    pot2pos=-1.096*10^4;
    av_original=av;
    newpos_original=newpos;
    %% Use this if you are taking manual derivatibe of position
    
    av=av_original;
    newpos=newpos_original;

    idx1 = find(pottime==newtime(2));
    av(1:idx1-1)=[];
    av=av-mean(av);
    pottime(1:idx1-1)=[];



    cutoff = (2*omega/pi)/(1/mean(diff(pottime)));
    [num,den] = butter(6,cutoff);

    av_butter = filtfilt(num,den,av);
    plot(pottime,av,pottime,av_butter)

    [~,idx] = find(max(av_butter));
    if idx==1
        pos = (av_butter-mean(av_butter(idx:idx+3))).*pot2pos;
    elseif idx==length(av_butter)
        pos = (av_butter-mean(av_butter(idx-3:idx))).*pot2pos;
    elseif idx > 2 || idx < length(av_butter)-1
        pos = (av_butter-mean(av_butter(idx-2:idx+2))).*pot2pos;
    else pos = (av_butter-mean(av_butter(idx-1:idx+1))).*pot2pos;
    end

    newpos=newpos-mean(newpos);
    pos=pos-mean(pos);

    plot(newtime,newpos,pottime,pos)


    %plot(newtime(2:end), newpos(2:end)-mean(newpos(2:end)), pottime(idx1:end), av(idx1:end)*pot2pos-mean(av(idx1:end)*pot2pos))

    %{
    % Prepare data for FFT
    newcom(newcom<25)=0;
    newvel(newvel<25)=0;
    window=sin(pi*newtime/newtime(end));
    newcom=(newcom-mean(newcom)).*window;
    newspd=(newvel-mean(newvel)).*window;
    
    npts = length(newtime);
    NFFT = 2^nextpow2(npts);
    Fs = npts/(newtime(end)-newtime(1));

    f = Fs/2*linspace(0,1,NFFT/2+1);
    
    % take the FFT
    X=fft(newcom,NFFT)/npts;
    Y=fft(newspd,NFFT)/npts;
    

    % Calculate the numberof unique points

    figure(3)
    subplot(211);
    plot(f./2,2*abs(X(1:NFFT/2+1)));
    title('X(f) : Magnitude response');
    ylabel('|X(f)|')
    subplot(212)
    plot(f./2,2*abs(Y(1:NFFT/2+1)));
    title('Y(f) : Magnitude response')
    xlabel('Frequency (Hz)');
    ylabel('|Y(f)|')

    figure(4)
    subplot(211)
    plot(f./2,angle(X(1:NFFT/2+1)));
    title('X(f) : Phase response');
    ylabel('Phase (rad)');
    subplot(212)
    plot(f./2,angle(Y(1:NFFT/2+1)));
    title('Y(f) : Phase response');
    xlabel('Frequency (Hz)');
    ylabel('Phase (rad)');

    % Determine the max value and max point.
    % This is where the sinusoidal
    % is located. See Figure 2.
    %{
    [~, idx_x] = max(abs(X));
    [~, idx_y] = max(abs(Y));
    X(idx_x)=0;
    Y(idx_y)=0;
    %}
    [mag_x, idx_x] = max(abs(X));
    mag_y = abs(Y(idx_x));
    % determine the phase difference
    % at the maximum point.
    px = angle(X(idx_x));
    py = angle(Y(idx_x));
    phase_lag(j) = py - px
    % determine the amplitude scaling
    amplitude_ratio(j) = rms(newspd(newspd>0))/rms(newcom(newcom>0))
    %amplitude_ratio(j) = mag_y/mag_x
   %} 
end

%{
for l=1:length(phase_lag)
    if phase_lag(l)>0
        phase_lag(l) = phase_lag(l)-2*pi;
    end
end

nyquist_freq = 2*pi/(2*mean(diff(newtime)));

% Make Bode Plot
figure(5)

subplot(2,1,1)
loglog(omega,amplitude_ratio)
ylim([10^-1 10^2])
xlim([10^0 2*10^1])
ylabel('Magnitude')
xlabel('Frequency [rad/s]')
title('Bode Plot of ECA Arm Shoulder Velocity Response')
set(gca,'fontsize', 14)
grid on

subplot(2,1,2)
semilogx(omega,(phase_lag*180/pi))
ylim([-360 0])
xlim([10^0 2*10^1])
ylabel('Phase [degrees]')
xlabel('Frequency [rad/s]')
text(1.25,-225,'NOTE: Nyquist freq. = ~22 rad/s','FontSize',12)
set(gca,'fontsize', 14)
grid on
%}

