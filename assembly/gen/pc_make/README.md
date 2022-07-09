# pc_make: peripheral chromatin generator

Date:               08-Jan-22
Version:            0.5.0

### Description of files in this directory
README.md           this file
init.qsub           PBS job script for running init.lmp with LAMMPS
input_data/*        Chip-Seq data to mark HC and EC domains on PC chain
src/*               C++ code for creating initial PC chain with input_data/*
Makefile            make file for compiling src/* into create_chromo
senescence.lam      template file with LAMMPS commands
senescence.sh       generates run_dir (using create_chromo and senescence.lam)
pc.sh               to setup and run simulation to obtain pc.data

### Attribution and Source of Original Code
The code in this directory is a modified version of a code obtained from
Polymer Modelling Predicts Chromosome Reorganisation in Senescence, [dataset]
                    (https://datashare.ed.ac.uk/handle/10283/3381)
under the "Creative Commons License: Attribution 4.0 International"
                    (https://creativecommons.org/licenses/by/4.0/).

The modified code in this directory (modifications listed below) is used to
generate the initial configuration (pc.data) of the peripheral chromatin (PC).
We cite the following for appropriate attribution of contributors of the
original code:

Chiang, Michael; Michieletto, Davide; Brackley, CA; Rattanavirotkul,
Nattaphong; Mohammed, Hisham; Marenduzzo, Davide; Chandra, Tamir. (2019).
Polymer Modelling Predicts Chromosome Reorganisation in Senescence, [dataset].
University of Edinburgh. https://doi.org/10.7488/ds/2593.

Michael Chiang, Davide Michieletto, Chris A. Brackley, Nattaphong
Rattanavirotkul, Hisham Mohammed, Davide Marenduzzo, Tamir Chandra,
Polymer Modeling Predicts Chromosome Reorganization in Senescence,
Cell Reports, Volume 28, Issue 12, 2019, Pages 3212-3223.e6, ISSN 2211-1247,
https://doi.org/10.1016/j.celrep.2019.08.045.
(https://www.sciencedirect.com/science/article/pii/S2211124719310939)

### List of modifications
1. src/create_chromo.cpp modified for compatibility with atom_style hybrid.
2. senescence.lam modified:
   a. for compatibility with atom_style hybrid.
   b. for improved communication cutoff.
   c. to remove redundant atoms and angles.
   d. to convert simulation lengthscale.
   e. to convert simulation energyscale.
   f. to export with filename 'pc.data'.
3. senescence.sh modified:
   a. for reproducibility with pseudo-randomness.
   b. to remove excess run time.
4. pc.sh added to automate most of the process to generate pc.data.
5. Replaced README file applicable to the original code with this file
   applicable to this modified code.

### Usage
0. A pc.data is already in parent directory; the procedure below is to
   optionally generate a new pc.data.
1. Run the pc.sh to setup the simulation by entering 'y' for the 1st question.
   Simulation is then run on the local machine with 'y' to 2nd quesiton.
2. Once the simulation completes, a pc.data will appear in run_dir with the
   following header:
-------------------------------------------------------------------------------
LAMMPS data file via write_data, version 27 May 2021, timestep = 500000

6303 atoms
4 atom types
6302 bonds
1 bond types
0 angles
1 angle types
0 ellipsoids

-122.5 122.5 xlo xhi
-122.5 122.5 ylo yhi
-122.5 122.5 zlo zhi

Masses

1 1
2 1
3 1
4 1
-------------------------------------------------------------------------------
   Replace the header with the following:
-------------------------------------------------------------------------------
Initial configuration of PC

6303 atoms
2 atom types
6302 bonds
1 bond types
0 angles
0 angle types
0 ellipsoids

-122.5 122.5 xlo xhi
-122.5 122.5 ylo yhi
-122.5 122.5 zlo zhi

Masses

1 4.358
2 4.358
-------------------------------------------------------------------------------
3. Move pc.data to ../../data/, replacing the previous pc.data.
4. Remove run_dir with "rm -rf run_dir".
