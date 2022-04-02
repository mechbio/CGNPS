#!/bin/bash

# An input script for setting parameters in the LAMMPS configuration file
# and for generating the initial conformation of the chromatin fibre

# Check that enough arguments are provided
if [ "$#" != 4 ]; then
    echo "usage: senescence.sh e_hh e_hl run run_dir"
    exit 1
fi

# Read and set the parameter values
e_hh=$1        # Heterochromatin-heterochromatin interaction energy
e_hl=$2        # Heterochromatin-lamina interaction energy
run=$3         # Trial number
run_dir=$4     # Output directory

e_ee=0.2       # Euchromatin-euchromatin interaction energy
chr_num=20     # The chromosome used in the modelling work

gen_chromo_exe="./create_chromo" # Program to create the chromatin fibre
lammps_script="senescence.lam" # Template LAMMPS configuration file

# Required bioinformatics data file
chromo_file="input_data/chromo_length.dat"
lam_file="input_data/LaminB1.bed"
het_file="input_data/H3K9me3.bed"

# Initial simulation box size
init_box_size=100
ilo=$(python -c "print -$init_box_size/2.0")
ihi=$(python -c "print $init_box_size/2.0")

# Final simulation box size
box_size=35
lo=$(python -c "print -$box_size/2.0")
hi=$(python -c "print $box_size/2.0")

# A function for generating random numbers
# max_seed=10000000
function get_rand(){
    rand=221
    # $(python -c "import random, sys; print random.randint(0,$max_seed)")
    echo $rand
}

# Timesteps and output frequencies for the equilibration
# and main simulation period (in Brownian time units)

# Part 1: Initial equilibration in the larger simulation box
prep1_printfreq=1000
prep1_seed=$(get_rand)
prep1_time_1=4000
prep1_time_2=2000
prep1_time_3=4000

# Part 2: Reducing the box size
prep2_printfreq=1000
prep2_seed=$(get_rand)
prep2_time=5000

# Part 3: Equilibrating with the lamina beads
prep3_printfreq=1000
prep3_seed=$(get_rand)
prep3_time=5000

# Part 4: Main simulation
run_printfreq=100
run_seed=$(get_rand)
run_time=5000

# For generating the lamina beads
lam_atoms=2000
lam_seed=$(get_rand)

# Integration time step size 
delta_t=0.01       

# Set the parameters of the interaction potentials
# Harmonic potential
e_harm=100.0

# Soft potential
e_soft=100.0

# LJ/cut potentials
sigma=1.0
cutoff=$(python -c "print '%.13f' % (1.8*$sigma)")

# Normalisation (ensure the minimum of the potential is actually epsilon)
norm=$(python -c "print '%.13f' % (1.0 + 4.0*(($sigma/$cutoff)**12-($sigma/$cutoff)**6))")
e_hh_norm=$(python -c "print '%.13f' % ($e_hh/$norm)")
e_hl_norm=$(python -c "print '%.13f' % ($e_hl/$norm)")
e_ee_norm=$(python -c "print '%.13f' % ($e_ee/$norm)")

# Set output file names
sim_name="sene_HH_${e_hh}_HL_${e_hl}_run_${run}"
init_file="init_${sim_name}.in"
run_dumpfile="run_${sim_name}.dump"
equil_endfile="equil_${sim_name}.out"
run_endfile="run_${sim_name}.out"

# Convert all time values to simulation time (i.e. rescale by delta_t)
prep1_time_1=$(bc <<< "$prep1_time_1/$delta_t")
prep1_time_2=$(bc <<< "$prep1_time_2/$delta_t")
prep1_time_3=$(bc <<< "$prep1_time_3/$delta_t")
prep1_printfreq=$(bc <<< "$prep1_printfreq/$delta_t")
prep2_time=$(bc <<< "$prep2_time/$delta_t")
prep2_printfreq=$(bc <<< "$prep2_printfreq/$delta_t")
prep3_time=$(bc <<< "$prep3_time/$delta_t")
prep3_printfreq=$(bc <<< "$prep3_printfreq/$delta_t")
run_time=$(bc <<< "$run_time/$delta_t")
run_printfreq=$(bc <<< "$run_printfreq/$delta_t")

# Create the output directory
run_dir="${run_dir}/${sim_name}"
if [ ! -d $run_dir ]; then
mkdir -p $run_dir
fi

# Create the LAMMPS configuration file based on the template file
lammps_file="${sim_name}.lam"
file="${run_dir}/${lammps_file}"
cp $lammps_script $file

# Replace macros in the copied template with the actual parameter values
perl -pi -e "s/INIT_FILE/${init_file}/g" $file

perl -pi -e "s/IXLO/${ilo}/g" $file
perl -pi -e "s/IXHI/${ihi}/g" $file
perl -pi -e "s/IYLO/${ilo}/g" $file
perl -pi -e "s/IYHI/${ihi}/g" $file
perl -pi -e "s/IZLO/${ilo}/g" $file
perl -pi -e "s/IZHI/${ihi}/g" $file

perl -pi -e "s/XLO/${lo}/g" $file
perl -pi -e "s/XHI/${hi}/g" $file
perl -pi -e "s/YLO/${lo}/g" $file
perl -pi -e "s/YHI/${hi}/g" $file
perl -pi -e "s/ZLO/${lo}/g" $file
perl -pi -e "s/ZHI/${hi}/g" $file

perl -pi -e "s/PREP1_PRINTFREQ/${prep1_printfreq}/g" $file
perl -pi -e "s/PREP1_SEED/${prep1_seed}/g" $file
perl -pi -e "s/PREP1_TIME_1/${prep1_time_1}/g" $file
perl -pi -e "s/PREP1_TIME_2/${prep1_time_2}/g" $file
perl -pi -e "s/PREP1_TIME_3/${prep1_time_3}/g" $file

perl -pi -e "s/PREP2_PRINTFREQ/${prep2_printfreq}/g" $file
perl -pi -e "s/PREP2_SEED/${prep2_seed}/g" $file
perl -pi -e "s/PREP2_TIME/${prep2_time}/g" $file

perl -pi -e "s/PREP3_PRINTFREQ/${prep3_printfreq}/g" $file
perl -pi -e "s/PREP3_SEED/${prep3_seed}/g" $file
perl -pi -e "s/PREP3_TIME/${prep3_time}/g" $file

perl -pi -e "s/RUN_PRINTFREQ/${run_printfreq}/g" $file
perl -pi -e "s/RUN_DUMPFILE/${run_dumpfile}/g" $file

perl -pi -e "s/RUN_SEED/${run_seed}/g" $file
perl -pi -e "s/RUN_TIME/${run_time}/g" $file

perl -pi -e "s/LAM_ATOMS/${lam_atoms}/g" $file
perl -pi -e "s/LAM_SEED/${lam_seed}/g" $file

perl -pi -e "s/DELTA_T/${delta_t}/g" $file

perl -pi -e "s/EHARM/${e_harm}/g" $file
perl -pi -e "s/ESOFT/${e_soft}/g" $file

perl -pi -e "s/EHCHC/${e_hh_norm}/g" $file
perl -pi -e "s/EHCNL/${e_hl_norm}/g" $file
perl -pi -e "s/EECEC/${e_ee_norm}/g" $file

perl -pi -e "s/SIGMA/${sigma}/g" $file

perl -pi -e "s/CUTOFF/${cutoff}/g" $file

perl -pi -e "s/EQUIL_ENDFILE/${equil_endfile}/g" $file
perl -pi -e "s/RUN_ENDFILE/${run_endfile}/g" $file

# Generate the chromatin fibre as a 3D random walk
seed=$(get_rand)
${gen_chromo_exe} $chromo_file $lam_file $het_file $chr_num $init_box_size $init_box_size $init_box_size $seed "${run_dir}/${init_file}"

# Relabel the centromere region (26.4 Mb to 29.4 Mb) as heterochromatin
awk '{if (NF==9&&$1>=2640&&$1<=2940) {$3=2; print} else {print}}' ${run_dir}/${init_file} > ${run_dir}/${init_file}.tmp
mv ${run_dir}/${init_file}.tmp ${run_dir}/${init_file}
