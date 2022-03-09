from matplotlib import pyplot as plt
import numpy as np

xflag = 'ecutrho'
xs=[]
ys=[]
list = ['161_k3_eb2000_ecut', '161_k3_eb2000_ecut_k12', '161_k3_eb2000']
for name in list:
    file_out = f'pwscf_{name}_cpu90.out'
    with open(file_out) as f:
        for line in f:
            if '!' in line:
                y = float(line.split(' ')[-2])*13.605698066 #eV
                print(y)
                ys.append(y)
    file_in = f'pwscf_{name}.in'
    with open(file_in) as f:
        for line in f:
            if xflag in line:
                x = float(line.split(' ')[-1])
                print(x)
                xs.append(x)
    
x = np.array(xs)
y = np.array(ys)
y = y-y.min()

plt.xlabel(xflag)
plt.ylabel('$E$, eV')
plt.plot(x, y, 'o')
plt.show()

xflag = 'ecutwfc'
xs=[]
ys=[]
list = ['161_k3_eb2000_ecut_k12_wfc60', '161_k3_eb2000_ecut_k12', '161_k3_eb2000_ecut_k12_wfc70']
for name in list:
    file_out = f'pwscf_{name}_cpu90.out'
    with open(file_out) as f:
        for line in f:
            if '!' in line:
                y = float(line.split(' ')[-2])*13.605698066 #eV
                print(y)
                ys.append(y)
    file_in = f'pwscf_{name}.in'
    with open(file_in) as f:
        for line in f:
            if xflag in line:
                x = float(line.split(' ')[-1])
                print(x)
                xs.append(x)
    
x = np.array(xs)
y = np.array(ys)
y = y-y.min()

plt.xlabel(xflag)
plt.ylabel('$E$, eV')
plt.plot(x, y, 'o')
plt.show()

xflag = 'ecutrho'
xs=[]
ys=[]
list = ['161_k3_eb2000', '161_k3_eb2000_dcorr']
for name in list:
    file_out = f'pwscf_{name}_cpu90.out'
    with open(file_out) as f:
        for line in f:
            if '!' in line:
                y = float(line.split(' ')[-2])*13.605698066 #eV
                print(y)
                ys.append(y)
    file_in = f'pwscf_{name}.in'
    with open(file_in) as f:
        for line in f:
            if xflag in line:
                x = float(line.split(' ')[-1])
                print(x)
                xs.append(x)
    
x = np.array(xs)
y = np.array(ys)
y = y-y.min()

plt.xlabel(xflag)
plt.ylabel('$E$, eV')
plt.plot(x, y, 'o')
plt.show()