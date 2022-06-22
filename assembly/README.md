# assembly: assembly module

Date:               10-Apr-22
Version:            0.7.0

### Description of files in this directory
README.md           this file
param/*             calculations of model parameters
gen/*               generates initial configuration of nuclear components
sim/*               assembly of nuclear components
viz/*               visualization of the assembled structure
data/*              storage of numerical data
fig/*               save visualizations

### Usage

1. Experimentally guided calculation of simulation units and model parameters
   is done in param/param.xlsx. The parameters have already been input into the
   files downstream.

2. Next, the gen/ne_csk_make/README.md and gen/pc_make/README.md have
   instructions on generating the initial configurations (data/ne_csk.data and
   data/pc.data) of the nuclear components.

3. Next, the sim/README.md has instructions on assembling the nuclear components
   into the CGNP structure (data/init.data).

4. Finally, the viz/README.md has instructions on visualization of the assembled
   structure.

5. The data/* directory (created at runtime) stores all numerical output. A
   description of files expected to be output in this directory is included
   below.

6. The visualizations can be saved to fig directory (created at runtime).

### Description of files in ./data/
ne_csk.data         initially generated NE structure with CSK
pc.data             initially generated PC structure
combined.data       combined structure
init.out            LAMMPS log output during assembly simulation
init.lammpstrj      particle positions during assembly simulation
init.dump_local     bond topology during assembly simulation
init.data           assembled structure (also called CGNE structure)
init.restart        restart file to initialize post-assembly simulations
equil.txt           equilibrium temperatures, energies and lateral tension.
combined2.data      combined structure processed for visualization
