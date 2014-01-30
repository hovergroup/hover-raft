%%

close all
clear

[t, force, torque] = readFTDataLVM('RUN01.lvm');

figure(1)
subplot(2,1,1)
plot(t, force(:,1), 'r')
hold on;
plot(t, force(:,2), 'g')
plot(t, force(:,3), 'b')
legend('x','y','z')
xlabel('Time [s]');
ylabel('Force [N]')
title('Free flight drilling - force measurement')

subplot(2,1,2)
plot(t, torque(:,1), 'r')
hold on;
plot(t, torque(:,2), 'g')
plot(t, torque(:,3), 'b')
legend('x','y','z')
xlabel('Time [s]');
ylabel('Torque [Nm]')
title('Free flight drilling - torque measurement')