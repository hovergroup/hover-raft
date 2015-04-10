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
pot2pos = -5400; %-4875.7 %(-4871.9+-4799.9+-4888.5 +-4939.5+-4878.8)/5;


ans='connecting to arduino...'
a = arduino('/dev/ttyACM0','uno');
ans='connected!'

for j=1:length(omega)
    
    mexmoos('CLOSE');
    pause(1);
    mexmoos('init','SERVERHOST','localhost','SERVERPORT','9000');
    pause(1);

    mexmoos('REGISTER','ECA_SHOULDER_SPEED',0);
    mexmoos('REGISTER','ECA_SHOULDER_POSITION',0);

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

        if (toc < 1)
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',0);
            cmd = 0;
        end
        if (toc > 1)
            av(pot_index)=readVoltage(a,0);
            pottime(pot_index)=toc;
            pot_index=pot_index+1;
            
            cmd = sin((toc-1)*omega(j))*50;
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

        if (toc > 3*2*pi/omega(j)+1)
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
    
    
    %% Use this if you are doing frequency response of position
    %{
    newcom = abs(newcom*120);
    newpos = newpos-min(newpos);
    position = position-min(position);
    
    %% Prepare data for FFT
    window=sin(pi*newtime/newtime(end));
    newcom=(newcom-mean(newcom)).*window;
    newpos=(newpos-mean(newpos)).*window;
    %}
    
    %% Use this if you are taking manual derivatibe of position
    newpos=(newpos-min(newpos));
    speed_fit = diff(newpos)./diff(newtime);
    speed_fit= abs(speed_fit);
    newspd = speed_fit*max(newvel)/(max(speed_fit)*120);
    newcom = abs((newcom(2:end)-mean(newcom(2:end))));
    newtime = newtime(2:end);
    newpos = newpos-min(newpos);
    position = position-min(position);
    newpos = newpos(2:end);
    newvel = newvel(2:end)./120;
    
    [~,idx] = find(max(av));
    if idx==1
        pos = (av-mean(av(idx:idx+3))).*pot2pos;
    elseif idx==length(av)
        pos = (av-mean(av(idx-3:idx))).*pot2pos;
    elseif idx > 2 || idx < length(av)-1
        pos = (av-mean(av(idx-2:idx+2))).*pot2pos;
    else pos = (av-mean(av(idx-1:idx+1))).*pot2pos;
    end
    spd = diff(filter(ones(1,5)/5,1,pos)-min(filter(ones(1,5)/5,1,pos)))./diff(pottime-2.5*mean(diff(time)));
    spd = abs(spd);
    spd = spd*max(newvel)/(max(spd)*120);
    spd = filter(ones(1,5)/5,1,spd);
    time=[];
    time = pottime(2:end);
    
    %%do you want to use moving average filter?
    plot(pottime, pos, pottime-2.5*mean(diff(time)), filter(ones(1,5)/5,1,pos)-min(filter(ones(1,5)/5,1,pos)))
    %% otherwise
    cutoff = (2*omega/pi)/(1/mean(diff(pottime)));
    [num,den] = butter(3, cutoff);
    pos_butter = filtfilt(num,den,pos);
    
    figure(2)
    subplot(211);
    plot(newtime, newpos, pottime,pos-min(pos)-300)
    legend('Command','Potentiometer Reading')
    title('Velocity Response')
    ylim([0 3000])
    grid;
    subplot(212);
    plot(newtime, newpos, pottime,pos_butter-min(pos_butter))
    title('Corrected Position')
    legend('Arm Reading','Potentiometer Filtered')
    grid;
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

