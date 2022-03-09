#!/usr/bin/env bash
# -*- coding: utf-8 -*-
name=$1

cat > pp.in << EOF
&INPUTPP
    prefix='${name}',
    outdir='./out/' 
    filplot = 'charge_${name}'
    plot_num = 0
 /

 &PLOT
    filepp(1) = 'charge_${name}'
    iflag = 3
    output_format = 5
    fileout = '${name}.rho.xsf'
 /
EOF

module purge
module load intel libraries/mkl intel-mpich/scalapack intel/mpich

mpirun -np 10 pp.x -inp pp.in

rm pp.in