#!python
# -*- coding: utf-8 -*-

from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import glob
import os
import re
import time


out=[]
names_c=[]
out_f=[]
out_nf=[]
out_c=[]
out_nc=[]
in_c=[]
c_finished=0
c_tot=0
for file in glob.iglob('**/*.out', recursive=True):
    if not 'slurm' in file:
        out.append(file)
        
c_tot=len(out)
        
for file in out:
    with open(file, 'r') as f:
        data = f.read()
        if 'JOB DONE' in data:
            #print(file, 'finished')
            c_finished+=1
            out_f.append(file)
            if 'convergence has been achieved' in data:
                out_c.append(file)
                m=re.sub(r"_cpu\d+.out", '',file)
                print(m)
                names_c.append(m)
                in_c.append(m+'.in')
            elif 'convergence NOT' in data:
                out_nc.append(file)
        else:
            #print(file, 'not finished')
            out_nf.append(file)
 
    

'''
while True:
    ans = input(f'Do you want to remove some unfinished? [y/n]:')
    if ans=='y' or ans=='Y':
        for file in out_nf:
            while True:
                ans = input(f'{file}\nDo you want to remove? [y/n]:')
                if ans=='y' or ans=='Y':
                    print('remove')
                    os.system(f'rm {file}')
                    break
                elif ans=='n' or ans=='N':
                    break
                else:
                    print('Answer [Yy/Nn]')
        break
    elif ans=='n' or ans=='N':
        break
    else:
        print('Answer [Yy/Nn]')
'''

df_c = pd.DataFrame({'name':names_c, 'out':out_c, 'in':in_c})

iterations, e, tm, am, wfc, rho, k, z, nat, t = [], [], [], [], [], [], [], [], [], []
for i, file in enumerate(out_c):
    with open(file, 'r') as f:
        data = f.read()
    matches = re.findall(r"convergence has been achieved in\s+\d+", data)
    iterations.append(int(matches[-1].split(' ')[-1]))
    matches = re.findall(r"internal energy .*", data)
    e.append(float(matches[-1].split(' ')[-2]))
    matches = re.findall(r"total magnetization .*", data)
    if len(matches)>0:
        tm.append(float(matches[-1].split(' ')[-3]))        
        matches = re.findall(r"absolute magnetization .*", data)
        am.append(float(matches[-1].split(' ')[-3]))
    else:
        tm.append(0)
        am.append(0)
    matches = re.findall(r"PWSCF\s+:\s+.*\s+CPU\s+.*\s+WALL", data)
    t_s=re.findall(r'CPU.*WALL', matches[-1])[-1]
    items=re.findall(r'\d+', t_s)
    mul=[60*24, 24, 1]
    days=0
    j=0
    for item in reversed(items):
        days+=int(item)/mul[j]
        j+=1
    t.append(days)
    with open(in_c[i], 'r') as f:
        data = f.read()
    matches = re.findall(r"ecutwfc.*", data)
    wfc.append(float(matches[-1].split(' ')[-1]))
    matches = re.findall(r"ecutrho.*", data)
    rho.append(float(matches[-1].split(' ')[-1]))
    matches = re.findall(r"K_POINTS automatic\n.*", data)
    k.append(float(matches[-1].split(' ')[-5]))
    matches = re.findall(r"0.0+\s+0.0+\s+.*", data)
    z.append(float(matches[-1].split(' ')[-1]))
    matches = re.findall(r"nat\s*=.*", data)
    nat.append(float(matches[-1].split(' ')[-1]))
    
df_c['iter']=iterations
df_c['time']=t
df_c['E']=np.array(e)*13.605698066 #eV
df_c['total magnetisation']=tm
df_c['absolute magnetisation']=am
df_c['ecutwfc']=wfc
df_c['ecutrho']=rho
df_c['ecutrho/wfc']=df_c['ecutrho']/df_c['ecutwfc']
df_c['k']=k
df_c['z']=z
df_c['nat']=nat
print(df_c)

def compare(X, Y, *args, xt=0.2, yt=0.8, offset=False):
    arg=[]
    val=[]
    t_arg=''
    for i in range(len(args)):
        if i%2!=0:
            continue

        if args[i]=='ecutwfc':
            arg.append('ecutwfc')
            val.append(args[i+1])
        elif args[i]=='ecutrho':
            arg.append('ecutrho')
            val.append(args[i+1])
        elif args[i]=='ecutrho/wfc':
            arg.append('ecutrho/wfc')
            val.append(args[i+1])
        elif args[i]=='k':
            arg.append('k')
            val.append(args[i+1])
        elif args[i]=='z':
            arg.append('z')
            val.append(args[i+1])
        elif args[i]=='nat':
            arg.append('nat')
            val.append(args[i+1])
    names=list(df_c)
    if X not in names or Y not in names:
        raise ValueError('unknown keyword')
        return
    if len(arg)>0:
        ind=(df_c[arg[0]]==val[0])
        for i in range(1,len(arg)):
            ind=ind*(df_c[arg[i]]==val[i])
            
        df=df_c[ind]
    else:
        df=df_c
    x=df[X]
    y=df[Y]
    if offset:
        c=y.min()
    else:
        c=0
    plt.plot(x,y-c,'o')
    plt.xlabel(X)
    plt.ylabel(Y)
    text=''
    for i in range(len(arg)):
        text+=f'{arg[i]} = {val[i]}\n' 
    xt=xt*(x.max()-x.min())+x.min()
    yt=yt*(y.max()-y.min())+(y.min()-c)
    plt.text(xt,yt,text)
    plt.show()
    return x, y

x,y=compare('ecutrho', 'E', 'ecutwfc', 50, 'k', 3, 'z', 18)
