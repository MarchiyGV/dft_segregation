#!/usr/bin/env bash

name=161_k3_eb2000_ecut
while [ True ]; do
if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "-n --name"
    exit 0;
elif [ "$1" = "--name" -o "$1" = "-n" ]; then
    name=$2
    shift 2
else
    break
fi
done

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

mv ${name}.pot.dat ./out/${name}.pot.dat
mv avg.dat ./out/${name}.pot_avg.dat
echo "output in ./out/${name}.pot_avg.dat and ./out/${name}.pot.dat"
rm average.in pp.in