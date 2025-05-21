import h5py
import os
import glob
import numpy as np
from scipy.signal import butter, filtfilt


### 여러 개의 trial을 포함한 h5파일 1개 Load
def load_trials_with_raw_data(file_path):
    trial_data_list = []

    with h5py.File(file_path, "r") as f:
        for trial_name in f.keys():
            trial = f[trial_name]

            # 개별 센서별 데이터 모두 불러오기
            trial_data = {
                'name': trial_name,
                
                'time': trial['time'][:],
                
                'emgL1': trial['emgL1'][:],
                'emgL2': trial['emgL2'][:],
                'emgL3': trial['emgL3'][:],
                'emgL4': trial['emgL4'][:],
                'emgR1': trial['emgR1'][:],
                'emgR2': trial['emgR2'][:],
                'emgR3': trial['emgR3'][:],
                'emgR4': trial['emgR4'][:],

                'imu1':  trial['imu1'][:],
                'imu2':  trial['imu2'][:],
                'imu3':  trial['imu3'][:],
                'imu4':  trial['imu4'][:],
                'imu5':  trial['imu5'][:],

                'button_ok': trial['button_ok'][:]
            }

            trial_data_list.append(trial_data)

    return trial_data_list


### 여러 개의 trial을 포함한 h5파일을 여러 개 포함하고 있는 폴더에 대한 Load
def load_all_trials_from_all_files(folder_path, pattern="cropped_*.h5"):
    all_trials = []

    file_list = sorted(glob.glob(os.path.join(folder_path, pattern)))
    print(f"총 {len(file_list)}개 파일을 로딩합니다.")

    for file_path in file_list:
        with h5py.File(file_path, "r") as f:
            for trial_name in f.keys():
                trial = f[trial_name]

                # 개별 센서별 데이터 모두 불러오기
                trial_data = {
                    'file': os.path.basename(file_path),

                    'name': trial_name,
                    
                    'time': trial['time'][:],
                    
                    'emgL1': trial['emgL1'][:],
                    'emgL2': trial['emgL2'][:],
                    'emgL3': trial['emgL3'][:],
                    'emgL4': trial['emgL4'][:],
                    'emgR1': trial['emgR1'][:],
                    'emgR2': trial['emgR2'][:],
                    'emgR3': trial['emgR3'][:],
                    'emgR4': trial['emgR4'][:],

                    'imu1':  trial['imu1'][:],
                    'imu2':  trial['imu2'][:],
                    'imu3':  trial['imu3'][:],
                    'imu4':  trial['imu4'][:],
                    'imu5':  trial['imu5'][:],

                    'button_ok': trial['button_ok'][:]
                }

                all_trials.append(trial_data)

    print(f"총 {len(all_trials)}개의 trial이 로딩되었습니다.")
    return all_trials




############################################################################################################################################
############################################################################################################################################
####################################################  Label  ###############################################################################
############################################################################################################################################
############################################################################################################################################

def generate_fixed_sequence_labels(trial_data, fs=100, k_ms=[200, 200, 200, 200]):
    """
    trial_data: dict with 'button_ok', 'time'
    fs: sampling frequency (Hz)
    k_ms: transition phase duration after OK button (in ms)
    """

    button_ok = np.squeeze(trial_data['button_ok'])
    T = len(button_ok)

    # OK 버튼 눌림 시점 (rising edge)
    pressed_indices = np.where(np.diff(button_ok.astype(int)) == 1)[0] + 1

    if len(pressed_indices) != 4:
        raise ValueError(f"Expected 4 OK button presses, but found {len(pressed_indices)}")


    # 실험 고정 순서
    phase_seq = [
        'Stand',
        'Stand-to-Sit',
        'Sit',
        'Sit-to-Stand',
        'Stand',
        'Stand-to-Walk',
        'Walk',
        'Walk-to-Stand',
        'Stand'
    ]


    labels = np.empty(T, dtype=object)

    idx = 0

    for i, press_idx in enumerate(pressed_indices):
        # 지속 phase
        n_delay = int((k_ms[i] / 1000.0) * fs)
        labels[idx:press_idx] = phase_seq[i * 2]

        # transition phase
        end_idx = min(press_idx + n_delay, T)
        labels[press_idx:end_idx] = phase_seq[i * 2 + 1]
        idx = end_idx

    # 마지막 지속 phase
    labels[idx:] = phase_seq[2 * len(pressed_indices)]

    return labels    



############################################################################################################################################
############################################################################################################################################
####################################################  EMG Filters  #########################################################################
############################################################################################################################################
############################################################################################################################################

def bandpass_filter(data, low_cutoff_freq=10, high_cutoff_freq=40, fs=100, order=4):
    nyquist_freq = 0.5 * fs
    low = low_cutoff_freq / nyquist_freq
    high = high_cutoff_freq / nyquist_freq
    b, a = butter(order, [low, high], btype='band')
    return filtfilt(b, a, data)


def lowpass_filter(data, cutoff_freq=5, fs=100, order=4):
    nyquist_freq = 0.5 * fs
    norm_cutoff = cutoff_freq / nyquist_freq
    b, a = butter(order, norm_cutoff, btype='low')
    return filtfilt(b, a, data)


def process_emg_signal(emg, low_cutoff_freq=10, high_cutoff_freq=40, fs=100, order=4):
    emg_bpf = bandpass_filter(emg, low_cutoff_freq = low_cutoff_freq, high_cutoff_freq = high_cutoff_freq, fs=fs, order = order)
    emg_rectified = np.abs(emg_bpf)
    return emg_rectified


def normalize_emg(data, method='zscore', mean_val=None, std_val=None, max_val=None):
    if method == 'zscore':
        if mean_val is None:
            mean_val = np.mean(data)
        if std_val is None:
            std_val = np.std(data)
        return (data - mean_val) / (std_val + 1e-8)
    elif method == 'max':
        if max_val is None:
            max_val = np.max(data)
        return data / (max_val + 1e-8)
    else:
        raise ValueError("method must be 'zscore' or 'max'")


def apply_filtered_emgL1(all_trial_data, lowcut=10, highcut=40, fs=100):
    all_trial_data_emgL1_fixed = []

    for trial in all_trial_data:
        trial_copy = trial.copy()  # 원본 유지

        emgL1 = fl(trial['emgL1'])
        filtered_emg = process_emg_signal(emgL1, lowcut = lowcut, highcut = highcut, fs=fs)

        trial_copy['emgL1'] = filtered_emg  # 필터링된 값으로 교체

        all_trial_data_emgL1_fixed.append(trial_copy)

    return all_trial_data_emgL1_fixed
