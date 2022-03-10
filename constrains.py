from matplotlib import pyplot as plt
import numpy as np
import pandas as pd

zmobile=0.1
path='geometries/GB_210/slab_161/'
file=path+'geometry_z23.txt'
outname='constr_z23.txt'

df = pd.read_csv(file, sep='\s+', engine='python', skiprows=1, 
                 names=['specie', 'x', 'y', 'z'], nrows=161)


z=df['z']
plt.hist(z[z<zmobile], bins=25)
plt.hist(z[z>zmobile], bins=75)
plt.axvline(zmobile, linestyle='--', color='r')
plt.text(zmobile+0.01, 1, f'$z={zmobile}$')
plt.show()

out=''
with open(file) as f:
    for line in f:
        line_new = line
        if 'Ag' in line or 'Ni' in line:
            z = float(line.split(' ')[-2])
            if z<=zmobile:
                line_new += '0 0 0'
                line_new = line_new.replace('\n', '')
                line_new+='\n'
        out+=line_new
                
print(out)
file=path+outname
with open(file, 'w') as f:
    f.write(out)
    
df_out = pd.read_csv(file, sep='\s+', engine='python', skiprows=1, 
                     names=['specie', 'x', 'y', 'z', 'cx', 'cy', 'cz'], 
                     nrows=161)

debug=df_out.fillna(-1)

zd=debug['z']

plt.hist(zd[debug['cz']==0], bins=25)
plt.hist(zd[debug['cz']==-1], bins=75)
plt.axvline(zmobile, linestyle='--', color='r')
plt.text(zmobile+0.01, 1, f'$z={zmobile}$')
plt.show()