#!/bin/bash
# -*- coding: utf-8 -*-

# This file is part of CGNPS - Coarse-Grained Nuclear Periphery Simulator.
#
# Copyright 2021, 2022 Pranjal Singh
#
# When contributing, please append a new line (e.g. # Copyright [Year] [Name])
# to the above copyright notice.
#
# See the README file in the top-level CGNPS directory.
# This software is distributed under the GNU General Public License.

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
