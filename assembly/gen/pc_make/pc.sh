#!/bin/bash
# -*- coding: utf-8 -*-

# CGNPS - Coarse-Grained Nuclear Periphery Simulator
#
# See the README file in the top-level CGNPS directory.
# This software is released under the GNU General Public License.

# -----------------------------------------------------------------------------
# This file (pc.sh) is for generating pc.data.
# -----------------------------------------------------------------------------

# date         :08-Jan-22
# version      :0.6.0
# usage        :./pc.sh
# sh_version   :4.2.46(2)-release

echo "Enter 'Y' or 'y' for yes."

read -p "Set up for run?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    make
    ./senescence.sh 1.0 2.0 0 run_dir
    make clean
fi

read -p "Run on local machine?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cd run_dir
    cd sene*
    mv sene* init.lmp
    # ulimit -s 10240
    mpirun lmp_mylammps < init.lmp > data/init.out
    # watch -n 1 "tail -10 data/init.out"
fi

exit 0
