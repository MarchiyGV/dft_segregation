#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from matplotlib import pyplot as plt
import numpy as np

xflag = 'ecutwfc'
xs=[]
ys=[]
dys=[]
list_out = ['pwscf_161_k3_eb2000_cpu90.out',
            'pwscf_161_k4_eb2000_cpu90.out',
            'pwscf_161_k5_eb2000_cpu90.out']
list_in = ['pwscf_161_k3_eb2000.in',
           'pwscf_161_k4_eb2000.in',
           'pwscf_161_k5_eb2000.in']
for file_out in list_out:
    with open(file_out) as f:
        for line in f:
            if 'total energy' in line and 'Ry' in line:
            
                y = float(line.split(' ')[-2])*13.605698066 #eV
                #print(y)
            if '!' in line:
                print(file_out, 'converged')
            if 'convergence NOT' in line:
                print(file_out, 'not converged')
            if 'estimated scf accuracy' in line:
                dy = float(line.split(' ')[-2])*13.605698066 #eV
                
    ys.append(y)
    dys.append(dy)
    
for file_in in list_in:
    with open(file_in) as f:
        for line in f:
            if xflag in line:
                x = float(line.split(' ')[-1])
                #print(x)
                xs.append(x)
    
        
x = np.array(xs)
y = np.array(ys)
dy = np.array(dys)
y = y-y.min()

x = np.arange(3,5+1)
xlab = 'num k'# xflag

plt.xlabel(xlab)
plt.ylabel('$E$, eV')
plt.plot(x, y, 'o')
plt.plot(x, y+dy, '.')
plt.plot(x, y-dy, '.')
plt.show()