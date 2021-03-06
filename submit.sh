#!/usr/bin/env bash

nbnd=""
cpu=90
nat=161
mixing_mode="local-TF"
beta=4.0d-01
k=3
ecutwfc=50
ecut_k=8
emaxpos_val=0.7
eopreg_val=0.05
task=scf
max_seconds=216000

while [ True ]; do
if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo "-n --name"
    echo "-g --geom"
    echo "-a --nat [def = ${nat}]"
    echo "-c --cpu [def = ${cpu}]"
    echo "-k [def = ${k}]"
    echo "--nbnd [def = ""; default from QE]"
    echo "-b --beta [def = ${beta}]"
    echo "--mixing_mode [def = ${mixing_mode}]"
    echo "--ecutrho-to-wfc [def = ${ecut_k}]"
    echo "--ecutwfc [def = ${ecutwfc}]"
    echo "--emaxpos [def = ${emaxpos}]"
    echo "--eopreg [def = ${eopreg}]"
    echo "--task [def = ${task}]"
    echo "--dpcorr"
    echo "--magnetic"
    echo "--max-seconds [def 216000] (2.5 days in s)"
    echo "--run [flag]"
    exit 0;
elif [ "$1" = "--nbnd" ]; then
    nbnd="nbnd = $2"
    shift 2
elif [ "$1" = "--beta" -o "$1" = "-b" ]; then
    beta=$2
    shift 2
elif [ "$1" = "--run" ]; then
    run=true
    shift 1
elif [ "$1" = "--ecutwfc" ]; then
    ecutwfc=$2
    shift 2
elif [ "$1" = "--ecutrho-to-wfc" ]; then
    ecut_k=$2
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
elif [ "$1" = "--emaxpos" ]; then
    emaxpos_val=$2
    dpcorr=true
    shift 2
elif [ "$1" = "--eopreg" ]; then
    eopreg_val=$2
    dpcorr=true
    shift 2
elif [ "$1" = "--task" ]; then
    task=$2
    shift 2
elif [ "$1" = "--dpcorr" ]; then
    dpcorr=true
    shift 1
elif [ "$1" = "--magnetic" ]; then
    magnetism=true
    shift 1
elif [ "$1" = "--max-seconds" ]; then
    max_seconds=$2
    shift 2
else
    break
fi
done

if [ -f "${name}/pwscf_cpu${cpu}.out" ]; then
    read -p "Output exists, do you want to continue? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Ok"
    else
        exit 0
    fi
fi

if [ $dpcorr ]; then
    tefield="tefield=.true."
    dipfield="dipfield=.true."
    eamp="eamp=0.0"
    edir="edir=3"
    emaxpos="emaxpos=$emaxpos_val"
    eopreg="eopreg=$eopreg_val"
else
    tefield="tefield=.false."
    dipfield="dipfield=.false."
    eamp=""
    edir=""
    emaxpos=""
    eopreg=""
fi 

if [ $magnetism ]; then
  mag1="starting_magnetization(1) = 0.1"
  mag2="starting_magnetization(2) = 0.2778"
  nspin="nspin = 2"
else
  mag1=""
  mag2=""
  nspin=""
fi

ecutrho=$((ecut_k*ecutwfc))
echo $ecutrho
geom=$(<$gpath)

mkdir ${name}

cat > ${name}/pwscf.in << EOF
&CONTROL
  max_seconds = ${max_seconds}
  calculation = '${task}'
  etot_conv_thr =   2.4000000000d-03
  forc_conv_thr =   1.0000000000d-04
  outdir = '../out/'
  prefix = '$name'
  pseudo_dir = '../pseudo/'
  verbosity = 'high'
  $tefield
  $dipfield
/
&SYSTEM
  degauss =   2.2049585400d-02
  ecutrho = ${ecutrho}
  ecutwfc = ${ecutwfc}
  ibrav = 0
  nat = $nat
  nosym = .false.
  ${nspin}
  ntyp = 2
  occupations = 'smearing'
  smearing = 'cold'
  ${mag1}
  ${mag2}
  $nbnd
  $eamp
  $edir   
  $emaxpos    
  $eopreg  
/
&ELECTRONS
  conv_thr =   3.2200000000d-08
  electron_maxstep = 120
  mixing_mode = '${mixing_mode}'
  mixing_beta = $beta
/
&IONS
  ion_dynamics='bfgs'
/
ATOMIC_SPECIES
Ag     107.8682 Ag_ONCV_PBEsol-1.0.upf
Ni     58.6934 ni_pbesol_v1.4.uspp.F.UPF
$geom
K_POINTS automatic
$k $k 1 0 0 0
EOF

echo "write pwscf_${name}.in"

cat > ${name}/task_cpu${cpu} << EOF
#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=$cpu
#SBATCH --job-name=$name
#SBATCH --mail-type=begin        # send email when job begins
#SBATCH --mail-type=end          # send email when job ends
#SBATCH --mail-user=georgiy.marchiy@mail.ioffe.ru

module purge
module load intel libraries/mkl intel-mpich/scalapack intel/mpich

mpirun --bind-to core -np $cpu pw.x -inp pwscf.in > pwscf_cpu${cpu}.out
EOF

echo "write ${name}/task_cpu${cpu}"

cat > ${name}/read_cpu${cpu}.sh << EOF
tail -f "pwscf_cpu${cpu}.out"
EOF
chmod +x ${name}/read_cpu${cpu}.sh

echo "write ${name}/read_cpu${cpu}.sh"
module purge
module load intel libraries/mkl intel-mpich/scalapack intel/mpich
if [ $run ]; then
    cd $name
    echo "sbatch task_cpu${cpu}"
    echo "" > "pwscf_cpu${cpu}.out"
    sbatch task_cpu${cpu}
    tail -f "pwscf_cpu${cpu}.out"
fi