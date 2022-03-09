import pandas as pd
from matplotlib import pyplot as plt
import numpy as np

name='161_k3_eb2000_dcorr'
df = pd.read_csv(f'out/{name}.save/pot_avg.dat', names=['z','a1', 'a2'], sep='\s+', engine='python')

z = np.array(df['z'])*0.529177
phi = np.array(df['a1'])*13.605698066

plt.plot(z, phi)
plt.xlabel('$z$, Angstrom')
plt.ylabel('$e\varphi$, eV')
plt.title('with dip corr')
plt.show()

name='161_k3_eb2000'
df = pd.read_csv(f'out/{name}.save/pot_avg.dat', names=['z','a1', 'a2'], sep='\s+', engine='python')

z = np.array(df['z'])*0.529177
phi = np.array(df['a1'])*13.605698066

plt.plot(z, phi)
plt.xlabel('$z$, Angstrom')
plt.ylabel('$e\varphi$, eV')
plt.title('without dip corr')
plt.show()