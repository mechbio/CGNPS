#!/bin/bash
# -*- coding: utf-8 -*-

# CGNPS - Coarse-Grained Nuclear Periphery Simulator
#
# See the README file in the top-level CGNPS directory.
# This software is released under the GNU General Public License.

# -----------------------------------------------------------------------------
# This file (run.sh) is used to run and monitor simulations.
# -----------------------------------------------------------------------------

# date         :02-Mar-22
# version      :0.7.0
# usage        :./run.sh
# sh_version   :4.2.46(2)-release

# Ensure output file exists
touch ../data/sim.out
# Parallel run
mpirun -np 4 lmp_mylammps < sim.lmp > ../data/sim.out
# Status
# watch -n 1 "tail -10 ../data/sim.out"

exit 0
