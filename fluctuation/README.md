# fluctuation: fluctuation module

Date:               10-Apr-22
Version:            0.7.0

### Description of files in this directory
README              the README (this) file
sim/*               recording fluctuation of nuclear surface
plt/*               computation and plotting of the fluctuation spectra
data/*              storage of numerical data
fig/*               save plot

### Usage

1. The sim/README has instructions to generate data/NM.lammpstrj which contains
   coordinates of fluctuating nuclear surface.

4. Next, the plt/README has instructions on computation and plotting of the
   fluctuation spectra.

5. The data/* directory (created at runtime) stores all numerical output. A
   description of files expected to be output in this directory is included
   below.

6. The plot is saved to fig directory (created at runtime).

### Description of files in ./data/
freq.dat           initially generated NE structure with CSK
NM.lammpstrj       NM particle positions
sim.out            LAMMPS log output during simulation
sim.lammpstrj      particle positions during simulation
sim.dump_local     bond topology during simulation
