# viz: visualization sub-module

Date:               10-Apr-22
Version:            0.7.0

### Description of files in this directory
README.md             this file
viz.sh                processing structure file for visualization (viz)
composition.ovito     viz of CGNP (Fig. 1a) and its composition (Fig. 1b)
slice-diagonal.ovito  viz of a slice of CGNP along the xy-diagonal (Fig. 1c)
surface.ovito         viz of nuclear surface deformation (Fig. 2a)

### Usage
1. Run the viz.sh to process ../data/combined.data.

2. On first time run, each OVITO file may require manual reloading of
   combined2.data, init.dump_local and init.lammpstrj from ../data/ into the
   'Data source' and the two 'Load trajectory' in the 'Modifications'
   pipelines respectively.

3. Then, one can generate Fig. 1a, 1b, 1c and 2a with the OVITO files. Note
   that for creating Fig. 1a from composition.ovito, Select Type should be
   checked in all pipelines.
