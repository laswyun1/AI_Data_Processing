import h5py



with h5py.File("cropped_20250520_233738.h5", "r") as f:
    for trial_name in f.values():
        print(trial_name)