import matplotlib.pyplot as plt
import numpy as np

data = np.loadtxt("CudaMONSEL\outputs\data3.txt")
SE = data[:, 4]
c = 140
r = (int)(SE.shape[0]/c)
# SE = SE/np.max(SE)
SE = SE / np.linalg.norm(SE)
SE = SE.reshape((r, c))
plt.imshow(SE, cmap='gray')
plt.show()
