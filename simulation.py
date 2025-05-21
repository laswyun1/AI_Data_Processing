import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D
from scipy.spatial.transform import Rotation as R
import h5py



class SensorData:
    def __init__(self, filePath):
        self.filePath = filePath



    def PrepareData(self):
        with h5py.File(self.filePath, "r") as f:
            time = f[""]



def 


















