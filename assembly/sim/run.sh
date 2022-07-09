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

# date         :08-Jan-22
# version      :0.6.0
# usage        :./run.sh
# sh_version   :4.2.46(2)-release

# Ensure output file exists
touch ../data/init.out
# Parallel run
mpirun -np 4 lmp_mylammps < init.lmp > ../data/init.out
# Status
# watch -n 1 "tail -10 ../data/init.out"

exit 0
