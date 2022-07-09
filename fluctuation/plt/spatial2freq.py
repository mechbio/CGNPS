#!/usr/bin/env python3
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
# This file (spatial2freq.py) converts time-sampled spatial data to time-averaged
# frequency spectra.
# -----------------------------------------------------------------------------

# date         :19-06-2021
# version      :0.7.0
# usage        :python3 spatial2freq.py inFile outFile
# py_version   :3.8

import sys,os,math
import numpy as np
import scipy.io as sio
import finufft

inFileName = sys.argv[1]
outFileName = sys.argv[2]

mat_contents = sio.loadmat(inFileName)

c = mat_contents['c']

print("Starting....")

M = len(c.item(0))
qmin = 1
qmax = round(np.sqrt(M)/4)
N1 = int(round(qmax*0.8)*2); # target grid will be N1-by-N1
N2 = int(N1/2);
ep = 1e-9
Lby2 = np.max(np.array(c.item(0))[:,0])
L = 2*Lby2;
print(L)
print(M)

fk = []
for i in range(c.shape[1]):
	cnp=np.array(c.item(i))
	xj = cnp[:,0]
	yj = cnp[:,1]
	cj = cnp[:,2]
	xj = (xj/Lby2)*np.pi
	yj = (yj/Lby2)*np.pi
	zavg = np.mean(cj)
	cj = (cj-zavg)
	xj = xj.astype('float64')
	yj = yj.astype('float64')
	cj = cj.astype('complex128')
	fk.append(finufft.nufft2d1(xj,yj,cj,(N1,N1),eps=ep))

print('Got fk... \n')
print(np.max(cj))

fkea = np.square(np.mean(np.absolute(np.array(fk)),axis=0))


def radial_profile(data, center):
    y, x = np.indices((data.shape))
    r = np.sqrt((x - center[0])**2 + (y - center[1])**2)
    r = r.astype(np.int64)

    tbin = np.bincount(r.ravel(), data.ravel())
    nr = np.bincount(r.ravel())
    radialprofile = tbin / nr
    return radialprofile

center, radi = (N2, N2), N2
rad = radial_profile(fkea, center)/(M*M)

outF = open(outFileName, "w")
outF.write('# Fluctuation spectrum\n')
outF.write('# q | <h^2>\n')

for i in range(N2):
	outF.write(str(i)+" "+str(rad[i])+"\n")
outF.close()
