clear all

%% Create Bode Plot of Arm's Velocity Response

% Initialize MOOS

% Define the frequency range to test the arm
%omega = 10.^(0:0.01:1.25);
omega = 0.25*pi;

mag  = zeros(1,1);
phase = zeros(1,1);
phase_lag = zeros(1,1);
amplitude_ratio = zeros(1,1);

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

    speed_index = 1;
    position_index = 1;
    exit = 0;
    tic;
    while (exit==0)
        msgs=mexmoos('FETCH');

        if (toc < 1)
            mexmoos('NOTIFY','ECA_SHOULDER_SPEED_CMD',0);
            cmd = 0;
        end
        if (toc > 1)
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

        if (toc > 10*2*pi/omega(j)+1)
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
    
    figure(1)
    plot(newcom)
    hold on
    plot(newspd)
    plot(newvel)
    hold off
    title('Normalized Arm Response Derivation Comparison')
    legend('Command','Calculated','Given')
    
    figure(2)
    subplot(211);
    plot(newtime, newvel, newtime, newcom)
    legend('newvel','newcom')
    title('Velocity Response')
    subplot(212);
    plot(time,position, newtime, newpos)
    title('Corrected Position')
    legend('Raw','Corrected')
    grid;
    
    % Prepare data for FFT
    window=sin(pi*newtime/newtime(end));
    newcom=(newcom-mean(newcom)).*window;
    newspd=(newvel-mean(newvel)).*window;

    % take the FFT
    X=fft(newcom);
    Y=fft(newspd);
    npts = length(newtime);

    % Calculate the numberof unique points
    NumUniquePts = ceil((npts+1)/2);
    
    
    figure(3)
    subplot(211);
    f = (0:NumUniquePts-1)*(omega(j)/(2*pi))/npts;
    plot(f,abs(X(1:NumUniquePts)));
    title('X(f) : Magnitude response');
    ylabel('|X(f)|')
    subplot(212)
    plot(f,abs(Y(1:NumUniquePts)));
    title('Y(f) : Magnitude response')
    xlabel('Frequency (Hz)');
    ylabel('|Y(f)|')

    figure(4)
    subplot(211)
    plot(f,angle(X(1:NumUniquePts)));
    title('X(f) : Phase response');
    ylabel('Phase (rad)');
    subplot(212)
    plot(f,angle(Y(1:NumUniquePts)));
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
    amplitude_ratio(j) = mag_y/mag_x
    
end

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
semilogx(omega,(-phase_lag*180/pi)-360)
ylim([-360 0])
xlim([10^0 2*10^1])
ylabel('Phase [degrees]')
xlabel('Frequency [rad/s]')
text(1.25,-225,'NOTE: Nyquist freq. = ~22 rad/s','FontSize',12)
set(gca,'fontsize', 14)
grid on
