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
# This file (plt.sh) is used to process data and plot with gnuplot.
# -----------------------------------------------------------------------------

# date         :14-Mar-2022
# version      :0.7.0
# usage        :./plt.sh
# sh_version   :4.2.46(2)-release

# sudo apt-get install python3
# sudo apt-get install python2
# sudo apt-get install python-numpy
# sudo apt-get install python3-numpy
# sudo apt-get install python-scipy
# sudo apt-get install python3-scipy
# cd ~
# wget http://archive.ubuntu.com/ubuntu/pool/universe/p/python-scipy/python-scipy_0.19.1-2ubuntu1_amd64.deb
# sudo apt-get install ./python-scipy_0.19.1-2ubuntu1_amd64.deb

# Clone repo of Pizza.py from GitHub and add this to ~/.bashrc
# export LAMMPS_PYTHON_TOOLS="path to Pizza.py directory"/src

python2 dump2spatial.py '../data/NM.lammpstrj' 'spatial.mat' #>/dev/null
# module load anaconda3
python3 spatial2freq.py 'spatial.mat' '../data/freq.dat'
rm spatial.mat
gnuplot spectra.gp
# rm fit.log

exit 0
