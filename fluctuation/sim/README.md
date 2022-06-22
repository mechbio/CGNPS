# sim: simulation sub-module

Date:               10-Apr-22
Version:            0.7.0

### Description of files in this directory
README.md           this file
run.sh              run and monitor simulation
commands.lmp        simulation commands for sim.lmp
sim.lmp             simulates the assembled CGNP as per commands.lmp
log.lammps          LAMMPS log file (created at runtime)


### Usage
0. In run.sh, replace the generic name of the LAMMPS command 'lmp_mylammps'
   with name of your build of LAMMPS.

1. Run the run.sh.
