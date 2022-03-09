#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from matplotlib import pyplot as plt
import numpy as np

xflag = 'ecutrho'
xs=[]
ys=[]
list_in = ['161_k3_eb2000_ecut_k14_wfc70/pwscf.in', 
        '161_k3_eb2000_ecut_k8_wfc70/pwscf.in', 
        'pwscf_161_k3_eb2000_ecut_k12_wfc70.in']
list_out = ['161_k3_eb2000_ecut_k14_wfc70/pwscf_cpu90.out', 
        '161_k3_eb2000_ecut_k8_wfc70/pwscf_cpu90.out', 
        'pwscf_161_k3_eb2000_ecut_k12_wfc70_cpu90.out']
for file_out in list_out:
    with open(file_out) as f:
        for line in f:
            if 'total energy' in line and 'Ry' in line:
                print(line)
                y = float(line.split(' ')[-2])*13.605698066 #eV
                print(y)
    ys.append(y)
for file_in in list_in:
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