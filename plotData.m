%% Reset ALL
clear all;
close all;
clc;

%% Load the h5 file
filename = 'cropped_20250520_233738.h5';

time = '/Sensor/Time/time';
emgL1 = '/Sensor/EMG/emgL1';
emgL2 = '/Sensor/EMG/emgL2';
emgL3 = '/Sensor/EMG/emgL3';
emgL4 = '/Sensor/EMG/emgL4';
emgR1 = '/Sensor/EMG/emgR1';
emgR2 = '/Sensor/EMG/emgR2';
emgR3 = '/Sensor/EMG/emgR3';
emgR4 = '/Sensor/EMG/emgR4';



imu1 = '/Sensor/IMU/imu1';
imu2 = '/Sensor/IMU/imu2';
imu3 = '/Sensor/IMU/imu3';
imu4 = '/Sensor/IMU/imu4';
imu5 = '/Sensor/IMU/imu5';

button_ok = '/Controller/button_ok';
button_a = '/Controller/button_a';
button_b = '/Controller/button_b';


% imu6 = '/Sensor/IMU/imu6';

data_time = (h5read(filename, time))';
data_emgL1 = (h5read(filename, emgL1))';
data_emgL2 = (h5read(filename, emgL2))';
data_emgL3 = (h5read(filename, emgL3))';
data_emgL4 = (h5read(filename, emgL4))';
data_emgR1 = (h5read(filename, emgR1))';
data_emgR2 = (h5read(filename, emgR2))';
data_emgR3 = (h5read(filename, emgR3))';
data_emgR4 = (h5read(filename, emgR4))';

data_imu1 = (h5read(filename, imu1))';
data_imu2 = (h5read(filename, imu2))';
data_imu3 = (h5read(filename, imu3))';
data_imu4 = (h5read(filename, imu4))';
data_imu5 = (h5read(filename, imu5))';
% data_imu6 = (h5read(filename, imu6))';

data_button_ok = (h5read(filename, button_ok))';
data_button_a = (h5read(filename, button_a))';
data_button_b = (h5read(filename, button_b))';



% plot(diff(data_time));
figure(1);
subplot(5,1,1);
plot(data_time, data_imu1);
legend("IMU1");
title("Quaternion of IMUs");
subplot(5,1,2);
plot(data_time, data_imu2);
legend("IMU2");
subplot(5,1,3);
plot(data_time, data_imu3);
legend("IMU3");
subplot(5,1,4);
plot(data_time, data_imu4);
legend("IMU4");
subplot(5,1,5);
plot(data_time, data_imu5);
legend("IMU5");
xlabel("Time[msec]");




figure(2);
subplot(8,1,1);
plot(data_time, data_emgL1);
legend("EMGL1");
title("EMG results");
subplot(8,1,2);
plot(data_time, data_emgL2);
legend("EMGL2");
subplot(8,1,3);
plot(data_time, data_emgL3);
legend("EMGL3");
subplot(8,1,4);
plot(data_time, data_emgL4);
legend("EMGL4");
subplot(8,1,5);
plot(data_time, data_emgR1);
legend("EMGR1");
subplot(8,1,6);
plot(data_time, data_emgR2);
legend("EMGR2");
subplot(8,1,7);
plot(data_time, data_emgR3);
legend("EMGR3");
subplot(8,1,8);
plot(data_time, data_emgR4);
legend("EMGR4");
xlabel("Time[msec]");

data_label_ok = [];
for i = 1:length(data_button_ok)
    if data_button_ok{i} == "TRUE" 
        data_label_ok(i) = 1;
    else
        data_label_ok(i) = 0;
    end
end

data_label_a = [];
for i = 1:length(data_button_a)
    if data_button_a{i} == "TRUE" 
        data_label_a(i) = 1;
    else
        data_label_a(i) = 0;
    end
end

data_label_b = [];
for i = 1:length(data_button_b)
    if data_button_b{i} == "TRUE" 
        data_label_b(i) = 1;
    else
        data_label_b(i) = 0;
    end
end

figure(3);
plot(data_time, data_label_ok, 'k', 'LineWidth', 2);
hold on;
plot(data_time, data_label_a, 'b', 'LineWidth', 2);     
plot(data_time, data_label_b, 'r', 'LineWidth', 2);
legend('Labeling', 'Start', 'Stop');
title("Button Labeling");
xlabel("Time[msec]");


figure(4);
plot(diff(data_time));
title("data chcek");




figure(5);
plot(data_time, data_label_a, 'b');
hold on;
plot(data_time, data_label_b, 'r');
plot(data_time, data_emgL2, 'k');



