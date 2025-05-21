%% Reset ALL
clear; clc; close all;

%% Load the h5 file
filename = 'sensor_20250520_214656.h5';

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
% imu6 = '/Sensor/IMU/imu6';

button_ok = '/Controller/button_ok';
button_a = '/Controller/button_a';
button_b = '/Controller/button_b';


data_time = h5read(filename, time);
data_emgL1 = (h5read(filename, emgL1));
data_emgL2 = (h5read(filename, emgL2));
data_emgL3 = (h5read(filename, emgL3));
data_emgL4 = (h5read(filename, emgL4));
data_emgR1 = (h5read(filename, emgR1));
data_emgR2 = (h5read(filename, emgR2));
data_emgR3 = (h5read(filename, emgR3));
data_emgR4 = (h5read(filename, emgR4));

data_imu1 = (h5read(filename, imu1))';
data_imu2 = (h5read(filename, imu2))';
data_imu3 = (h5read(filename, imu3))';
data_imu4 = (h5read(filename, imu4))';
data_imu5 = (h5read(filename, imu5))';
% data_imu6 = (h5read(filename, imu6))';

data_button_ok = (h5read(filename, button_ok));
data_button_a  = (h5read(filename, button_a));
data_button_b  = (h5read(filename, button_b));

data_label_ok = strcmp(data_button_ok, 'TRUE');
data_label_a  = strcmp(data_button_a, 'TRUE');
data_label_b  = strcmp(data_button_b, 'TRUE');

%%

L = length(data_label_ok);

rising_edge_ok = uint8([false; diff(data_label_ok) == 1]);
rising_edge_a  = uint8([false; diff(data_label_a)  == 1]);
rising_edge_b  = uint8([false; diff(data_label_b)  == 1]);

rising_idx_ok = find(rising_edge_ok == true);
rising_idx_a  = find(rising_edge_a  == true);
rising_idx_b  = find(rising_edge_b  == true);

valid_pairs = [];

for i = 1:length(rising_idx_a)
    start_idx = rising_idx_a(i);
    next_stop_idx = rising_idx_b(find(rising_idx_b > start_idx, 1, 'first'));

    if isempty(next_stop_idx)
        continue;
    end

    % 검정 라벨이 정확히 4개 포함되어 있는지 확인
    num_ok_in_range = sum(rising_idx_ok >= start_idx & rising_idx_ok <= next_stop_idx);
    if num_ok_in_range == 4
        valid_pairs = [valid_pairs; start_idx, next_stop_idx];  % 행렬에 쌍 저장
    end
end

% === 유효한 쌍에 대해 Cropping 및 저장 여부 확인 ===
cropped_data = {};
for count = 1:size(valid_pairs, 1)
    start_idx = valid_pairs(count, 1);
    stop_idx  = valid_pairs(count, 2);

    % --- 데이터 자르기 ---
    cropped.time = data_time(start_idx:stop_idx,1);
    cropped.imu1 = data_imu1(start_idx:stop_idx,:);
    cropped.imu2 = data_imu2(start_idx:stop_idx,:);
    cropped.imu3 = data_imu3(start_idx:stop_idx,:);
    cropped.imu4 = data_imu4(start_idx:stop_idx,:);
    cropped.imu5 = data_imu5(start_idx:stop_idx,:);

    cropped.emgL1 = data_emgL1(start_idx:stop_idx,1);
    cropped.emgL2 = data_emgL2(start_idx:stop_idx,1);
    cropped.emgL3 = data_emgL3(start_idx:stop_idx,1);
    cropped.emgL4 = data_emgL3(start_idx:stop_idx,1);
    cropped.emgR1 = data_emgR1(start_idx:stop_idx,1);
    cropped.emgR2 = data_emgR2(start_idx:stop_idx,1);
    cropped.emgR3 = data_emgR3(start_idx:stop_idx,1);
    cropped.emgR4 = data_emgR3(start_idx:stop_idx,1);

    cropped.button_ok = rising_edge_ok(start_idx:stop_idx,1);
    cropped.button_a  = rising_edge_a(start_idx:stop_idx,1);
    cropped.button_b  = rising_edge_b(start_idx:stop_idx,1);

    % --- 시각화 ---
    imufig = figure('Position',[50 100 250 800]);
    subplot(5,1,1); plot(cropped.time, cropped.imu1); legend("IMU1"); xlim([-inf inf]); title("Quaternion of IMUs"); xlim([-inf inf]);
    subplot(5,1,2); plot(cropped.time, cropped.imu2); legend("IMU2"); xlim([-inf inf]);
    subplot(5,1,3); plot(cropped.time, cropped.imu3); legend("IMU3"); xlim([-inf inf]);
    subplot(5,1,4); plot(cropped.time, cropped.imu4); legend("IMU4"); xlim([-inf inf]);
    subplot(5,1,5); plot(cropped.time, cropped.imu5); legend("IMU5"); xlim([-inf inf]); xlabel("Time[msec]");

    emgfig = figure('Position',[300 100 250 800]);
    subplot(8,1,1); plot(cropped.time, cropped.emgL1); legend("EMGL1"); xlim([-inf inf]); title("EMG results");
    subplot(8,1,2); plot(cropped.time, cropped.emgL2); legend("EMGL2"); xlim([-inf inf]);
    subplot(8,1,3); plot(cropped.time, cropped.emgL3); legend("EMGL3"); xlim([-inf inf]);
    subplot(8,1,4); plot(cropped.time, cropped.emgL4); legend("EMGL4"); xlim([-inf inf]);
    subplot(8,1,5); plot(cropped.time, cropped.emgR1); legend("EMGR1"); xlim([-inf inf]);
    subplot(8,1,6); plot(cropped.time, cropped.emgR2); legend("EMGR2"); xlim([-inf inf]);
    subplot(8,1,7); plot(cropped.time, cropped.emgR3); legend("EMGR3"); xlim([-inf inf]);
    subplot(8,1,8); plot(cropped.time, cropped.emgR4); legend("EMGR4"); xlim([-inf inf]); xlabel("Time[msec]");

    labelfig = figure('Position',[550 100 250 800]); hold on;
    plot(cropped.time, cropped.button_ok, 'k', 'LineWidth', 2); xlim([-inf inf]);
    plot(cropped.time, cropped.button_a,  'b', 'LineWidth', 2); xlim([-inf inf]);
    plot(cropped.time, cropped.button_b,  'r', 'LineWidth', 2); xlim([-inf inf]);
    legend('Labeling', 'Start', 'Stop');
    title("Button Labeling (Check 4 black lines)");
    xlabel("Time[msec]");

    % --- 저장 여부 질의 ---
    % while true
    %     user_input = input('Do you want to save? (y/n): ', 's');
    %     if strcmpi(user_input, 'y')
    %         cropped_data{end+1} = cropped;
    %         disp('Data Appended.');
    %         close all
    %         break;
    %     elseif strcmpi(user_input, 'n')
    %         disp('Data Rejected.');
    %         close all
    %         break;
    %     else
    %         disp('Wrong input.');
    %     end
    % end
end

disp('Finish appending.');

%%

cropped_filename = strrep(filename, 'sensor_', 'cropped_');
for i = 1:length(cropped_data)
    trial = cropped_data{i};
    group_prefix = sprintf('/trial_%d', i);
    
    % 저장할 필드 리스트
    fields = fieldnames(trial);
    
    for j = 1:numel(fields)
        name = fields{j};
        path = sprintf('%s/%s', group_prefix, name);
        data = trial.(name);

        % h5create는 처음만 실행 (존재하면 skip 또는 try-catch)
        if ~isfile(cropped_filename) || ~h5exists(cropped_filename, path)
            h5create(cropped_filename, path, size(data), 'Datatype', class(data));
        end

        % 데이터 저장
        h5write(cropped_filename, path, data);
    end
end

disp('File created.');

%%
function exists = h5exists(filename, path)
    try
        info = h5info(filename, path);
        exists = ~isempty(info);
    catch
        exists = false;
    end
end






