
#!/usr/bin/env bash

cat > pp.in << EOF
&INPUTPP
    prefix='161_k3_eb2000_ecut',
    outdir='./out' 
    filplot='pot.dat'
    plot_num=11
/
EOF

cat > average.in << EOF
1
pot.dat
1.0
3000
3
3.00000
EOF

pp.x <pp.in
average.x <average.in