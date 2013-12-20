function [ output_args ] = plotAll( t, x, v5, count, color, successes, failures, imageWidth, imageHeight )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% PLOT: POSITION
            subplot(2,2,1)
%             hold off;
%             imshow(im(:,:,1));
%             hold on;
            if(count<100)
                plot(x(1,1:count), x(2,1:count), [color,'.'], 'MarkerSize', 15,'LineWidth',3);
            else
                plot(x(1,(count-99):count), x(2,(count-99):count), [color,'.'], 'MarkerSize', 15,'LineWidth',3);
            end
            xlabel('x [px]')
            ylabel('y [px]')
            xlim([0 imageWidth-1])
            ylim([0 imageHeight-1])
            grid on
            %T = toc;
            title(['Frame rate: ', num2str(5.0/(t(count)-t(count-4))), ' S/F: ', num2str(successes), '/', num2str(failures)]);

            % PLOT: HEADING
            subplot(2,2,2)
            if(count<100)
                plot(t(1:count),rad2deg(x(3,1:count)),['-',color,'.'],'LineWidth',3);
            else
                plot(t((count-99):count),rad2deg(x(3,(count-99):count)),['-',color,'.'],'LineWidth',3);
            end
            xlabel('Time [s]')
            ylabel('Heading [deg]');       
            grid on
        

            % PLOT: VELOCITY
            subplot(2,2,3)
            if(count<100)
                hold off;
                plot(t(1:count),(v5(1,1:count)),['-',color,'.'],'LineWidth',3);
                hold on
                plot(t(1:count),(v5(2,1:count)),['--',color,'.'],'LineWidth',3);
            else
                hold off;
                plot(t((count-99):count),(v5(1,(count-99):count)),['-',color,'.'],'LineWidth',3);
                hold on
                plot(t((count-99):count),(v5(2,(count-99):count)),['--',color,'.'],'LineWidth',3);
            end
            xlabel('Time [s]')
            ylabel('Speed [px/s]');       
            grid on

            % PLOT: YAW RATE
            subplot(2,2,4)
            if(count<100)
                hold off;
                plot(t(1:count),rad2deg(v5(3,1:count)),['-',color,'.'],'LineWidth',3);
            else
                hold off;
                plot(t((count-99):count),rad2deg(v5(3,(count-99):count)),['-',color,'.'],'LineWidth',3);
            end
            xlabel('Time [s]')
            ylabel('Yaw rate [deg/s]');       
            grid on            

        drawnow;
end

