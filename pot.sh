#!/usr/bin/env bash

name=161_k3_eb2000_ecut
while [ True ]; do
if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "-n --name"
    exit 0;
elif [ "$1" = "--name" -o "$1" = "-n" ]; then
    name=$2
    shift 2
elif [ "$1" = "--all" -o "$1" = "-a" ]; then
    all=true
    shift 1
else
    break
fi
done
module purge
module load intel libraries/mkl intel-mpich/scalapack intel/mpich

for path in `ls out/*.save`
do
echo $path
name=${path%".save:"}
name=${name#"out/"}
echo $name
cat > pp.in << EOF
&INPUTPP
    prefix='${name}',
    outdir='./out/' 
    filplot='${name}.pot.dat'
    plot_num=11
/
EOF

cat > average.in << EOF
1
${name}.pot.dat
1.0
3000
3
3.00000
EOF

echo run
pp.x <pp.in
average.x <average.in

mv ${name}.pot.dat ./out/${name}.save/pot.dat
mv avg.dat ./out/${name}.save/pot_avg.dat

echo "output in ./out/${name}.save/pot_avg.dat and ./out/${name}.save/pot.dat"
rm average.in pp.in

done