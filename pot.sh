#!/usr/bin/env bash
cpu=1
while [ True ]; do
if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "-n --name"
    echo "-a -all"
    exit 0;
elif [ "$1" = "--name" -o "$1" = "-n" ]; then
    name=$2
    shift 2
elif [ "$1" = "--job" -o "$1" = "-j" ]; then
    cpu=$2
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

if [ $all ]; then
    list=`ls out/*.save`
else
    list="out/${name}.save:"
fi
echo $list

for path in $list
do
if [[ -d ${path%":"} ]]; then
echo "path: $path"
name=${path%".save:"}
name=${name#"out/"}
echo "name: $name"


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
mpirun -np ${cpu} pp.x -inp pp.in
average.x -inp average.in

mv ${name}.pot.dat ./out/${name}.save/pot.dat
mv avg.dat ./out/${name}.save/pot_avg.dat

echo "output in ./out/${name}.save/pot_avg.dat and ./out/${name}.save/pot.dat"
rm average.in pp.in

fi
done