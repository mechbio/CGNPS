#!/usr/bin/env python2
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
# This file (dump2spatial.py) converts LAMMPS dumped data to time-sampled
# spatial data.
# -----------------------------------------------------------------------------

# date         :19-Jun-2021
# version      :0.7.0
# usage        :python2 dump2spatial.py inFile outFile
# py_version   :2.7

import sys,os,math
import numpy as np
import scipy.io as sio
path = os.environ["LAMMPS_PYTHON_TOOLS"]
sys.path.append(path)

from dump import dump
inFileName = sys.argv[1]
outFileName = sys.argv[2]

d = dump(inFileName)

ttotal = d.time()
dstacks = np.zeros((len(ttotal),), dtype=np.object)

for t in range(0,len(ttotal)):
	dstacks[t] = np.array(np.transpose(d.vecs(ttotal[t],'x','y','z')))

sio.savemat(outFileName, {'c':dstacks})
