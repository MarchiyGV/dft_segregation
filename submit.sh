#!/usr/bin/env bash

nbnd=""
cpu=90
nat=161
mixing_mode="'local-TF'"
beta=4.0d-01
k=3

while [ True ]; do
if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "-n --name"
    echo "-g --geom"
    echo "-a --nat [def = 161]"
    echo "-c --cpu [def = 90]"
    echo "-k [def = 3]"
    echo "--nbnd [def = ""; default from QE]"
    echo "-b --beta [def = 0.4]"
    echo "--mixing_mode [def = 'local-TF']"
    exit 0;
elif [ "$1" = "--nbnd" ]; then
    nbnd="nbnd = $2"
    shift 2
elif [ "$1" = "--beta" -o "$1" = "-b" ]; then
    beta=$2
    shift 2
elif [ "$1" = "--mixing_mode" ]; then
    mixing_mode=$2
    shift 2
elif [ "$1" = "--name" -o "$1" = "-n" ]; then
    name=$2
    shift 2
elif [ "$1" = "--geom" -o "$1" = "-g" ]; then
    gpath=$2
    shift 2
elif [ "$1" = "--nat" -o "$1" = "-a" ]; then
    nat=$2
    shift 2
elif [ "$1" = "--cpu" -o "$1" = "-c" ]; then
    cpu=$2
    shift 2
elif [ "$1" = "-k" ]; then
    k=$2
    shift 2
else
    break
fi
done


geom=$(<$gpath)

cat > pwscf_${name}.in << EOF
&CONTROL
  calculation = 'scf'
  etot_conv_thr =   2.4000000000d-03
  forc_conv_thr =   1.0000000000d-04
  outdir = './out/'
  prefix = '$name'
  pseudo_dir = './pseudo/'
  verbosity = 'high'
/
&SYSTEM
  degauss =   2.2049585400d-02
  ecutrho =   3.6000000000d+02
  ecutwfc =   5.0000000000d+01
  ibrav = 0
  nat = $nat
  nosym = .false.
  nspin = 2
  ntyp = 2
  occupations = 'smearing'
  smearing = 'cold'
  starting_magnetization(1) =   1.0000000000d-01
  starting_magnetization(2) =   2.7777777778d-01
  $nbnd
/
&ELECTRONS
  conv_thr =   3.2200000000d-08
  electron_maxstep = 80
  mixing_mode = $mixing_mode
  mixing_beta = $beta
/
ATOMIC_SPECIES
Ag     107.8682 Ag_ONCV_PBEsol-1.0.upf
Ni     58.6934 ni_pbesol_v1.4.uspp.F.UPF
$geom
K_POINTS automatic
$k $k 1 0 0 0
EOF

cat > task_${name}_cpu${cpu} << EOF
#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=$cpu
#SBATCH --job-name=$name
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=georgiy.marchiy@mail.ioffe.ru
module purge
module load intel libraries/mkl intel-mpich/scalapack intel/mpich

mpirun --bind-to core -np $cpu pw.x -inp pwscf_${name}.in > pwscf_${name}_cpu${cpu}.out
EOF

echo "" > "pwscf_${name}_cpu${cpu}.out"
sbatch task_${name}_cpu${cpu}
tail -f "pwscf_${name}_cpu${cpu}.out"