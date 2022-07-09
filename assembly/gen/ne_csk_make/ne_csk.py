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
# This file (ne_csk.py) generates configuration data file (ne_csk.data)
# which will be read by init.lmp.
# -----------------------------------------------------------------------------

# date         :19-Jan-22
# version      :0.6.0
# usage        :python ne_csk.py 2.5
# py_version   :3.7

# Initialize ==================================================================

import sys
import numpy as np
import random

scl = float(sys.argv[1]) # scale of simulation box
L = 100*scl # Length of sides of simulation box in x and y (Lx = Ly = L)
sd = 221 # seed for random generator

mNM = 1.237
mNPC = 60.00
mNLA = 0.070
mNLB = 0.068
mFA = 0.105
mMT = 1.300

sclsq = scl*scl

# Simulation box
xlo = -L/2.0
xhi = L/2.0
ylo = -L/2.0
yhi = L/2.0
zlo = -300.0
zhi = 150.0

# Initialize counts
natoms = 0
nbonds = 0
nangles = 0
nellipsoids = 0
natomTs = 0
nbondTs = 0
nangleTs = 0
nmols = 0

# Functions ===================================================================

def monolayer(S,d,H):
    """A 2D triangular lattice of size SxS with points spaced by d.
    """

    xyz = np.zeros(3)

    trimaker = np.asarray([[1.0, np.cos(np.pi/3.0), 0.0],
                           [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]])
    Sx = S*(1.0+np.tan(np.pi/3.0))
    sx = d
    Sy = S
    sy = d*np.sin(np.pi/3.0)

    for i in range(int(Sx/sx)):
        for j in range(int(Sy/sy)):
            x0 = i*sx-Sx/2.0
            y0 = j*sy-Sy/2.0
            z0 = H
            xyz0 = trimaker.dot([x0, y0, z0])
            if np.abs(xyz0[0])<S/2.0:
                xyz = np.vstack([xyz, xyz0])

    xyz = xyz[1:]

    return xyz

def distrib(Nb,NBf,NAf,ft0,ft1):
    """Filament distribution.
    """

    Bf = []
    Af = []
    for i in range(len(Nb)):
        Bf = np.concatenate((Bf, Nb[i]*np.ones(NBf[i])))
        Af = np.concatenate((Af, Nb[i]*np.ones(NAf[i])))

    nfil = np.sum(NBf)+np.sum(NAf)
    orderedtypes = np.concatenate((ft0*np.ones(np.sum(NAf)),
                                   ft1*np.ones(np.sum(NBf))))
    orderedNbs = np.concatenate((Af, Bf))
    p = np.random.RandomState(seed=sd).permutation(nfil)
    filtype = orderedtypes[p].astype(int)
    filNb = orderedNbs[p].astype(int)

    return filtype, filNb

def filaments(S,d,H,filtype,filNb,natoms,nbonds,nangles,nmols):
    """Filaments grown on 2D triangular lattice of size SxS
    with filaments spaced by d and beads spaced by r0/r1.
    """
    atoms = np.zeros(9)
    bonds = np.zeros(4)
    angles = np.zeros(5)

    trimaker = np.asarray([[1.0, np.cos(np.pi/3.0), 0.0],
                           [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]])
    Sx = S*(1.0+np.tan(np.pi/3.0))
    sx = d
    Sy = S
    sy = d*np.sin(np.pi/3.0)

    nfil = len(filtype)
    atom_id = natoms
    bond_id = nbonds
    angle_id = nangles
    fil = 0
    for i in range(int(Sx/sx)):
        for j in range(int(Sy/sy)):
            x0 = i*sx-Sx/2.0
            y0 = j*sy-Sy/2.0
            z0 = H
            xyz0 = trimaker.dot([x0, y0, z0])
            if np.abs(xyz0[0])<S/2.0:
                if fil < nfil:
                    fil += 1
                    seq=0
                    Nb = filNb[fil-1]
                    for k in range(Nb):
                        seq += 1
                        atom_id += 1

                        atomtype = filtype[fil-1]

                        if filtype[fil-1] == 3:
                            btype = 1
                            atype = 1
                            atommass = mNLA
                            ri = -2.0
                        if filtype[fil-1] == 4:
                            btype = 1
                            atype = 1
                            atommass = mNLB
                            ri = -2.0
                        if filtype[fil-1] == 7:
                            btype = 2
                            atype = 2
                            atommass = mFA
                            ri = 1.0
                        if filtype[fil-1] == 8:
                            btype = 3
                            atype = 3
                            atommass = mMT
                            ri = 1.2

                        atoms0 = [atom_id, atomtype, xyz0[0], xyz0[1],
                                  xyz0[2]+ri*k, 0, atommass,
                                  nmols+fil, k]
                        atoms = np.vstack([atoms, atoms0])

                        if seq<Nb:
                            bond_id += 1
                            bonds0 = [bond_id, btype, atom_id, atom_id+1]
                            bonds = np.vstack([bonds, bonds0])

                        if seq>1 and seq<Nb:
                            angle_id += 1
                            angles0 = [angle_id, atype,
                                       atom_id-1, atom_id, atom_id+1]
                            angles = np.vstack([angles, angles0])

    atoms = atoms[1:]
    bonds = bonds[1:]
    angles = angles[1:]

    return atoms, bonds, angles, fil

# Molecules ===================================================================

# NM --------------------------------------------------------------------------
d0 = 2.0
d1 = d0*1.08
h = 0.0

atoms0 = monolayer(L,d1,h)
natoms0 = np.shape(atoms0)[0]

nNPC = int(6*sclsq)
listNPC = np.ones(nNPC)
nNM = int(natoms0-nNPC)
listNM = np.ones(nNM)
orderedtypes = np.concatenate((2*listNPC, 1*listNM))
orderedmasses = np.concatenate((mNPC*listNPC, mNM*listNM))
p = np.random.RandomState(seed=sd).permutation(natoms0)
types0 = orderedtypes[p]
mass = orderedmasses[p]
shape0 = [d0, d0, d0]
volm = (4.0/3.0*(np.pi*shape0[0]*shape0[1]*shape0[2])/8.0)
density0 = mass/volm
ellipsoidflag0 = 1
molecule_ID0 = 0
charge0 = 0

nquat=[0, -1, 0]
thetaquat=np.pi/2.0
quat = [np.cos(thetaquat/2.0),nquat[0]*np.sin(thetaquat/2.0),
        nquat[1]*np.sin(thetaquat/2.0),nquat[2]*np.sin(thetaquat/2.0)]

natoms += natoms0
nellipsoids += natoms0
natomTs += 2

print(f'{natoms} NM particles generated.')

# NL --------------------------------------------------------------------------
d1 = 7.335
h = -5.0
Nb  = [9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 43]
NBf = np.asarray([3, 12, 16, 11, 11, 7, 4, 2, 1, 0, 1, 0])*sclsq
NAf = np.asarray([7, 24, 33, 21, 23, 15, 8, 3, 3, 1, 0, 1])*sclsq
NAf = np.rint(NAf).astype(int)
NBf = np.rint(NBf).astype(int)

(filtype, filNb) = distrib(Nb,NBf,NAf,3,4)
(atoms1, bonds1, angles1, fil) = filaments(L-2.0,d1,h,filtype,filNb,
                                 natoms,nbonds,nangles,nmols)

natoms1 = np.shape(atoms1)[0]
nbonds1 = np.shape(bonds1)[0]
nangles1 = np.shape(angles1)[0]

natoms += natoms1
nbonds += nbonds1
nangles += nangles1
natomTs += 2 # NLA, NLB
nbondTs += 4 # NL fil, CL, IL-A, IL-B
nangleTs += 1 # NL fil
nmols += fil

print(f'{fil} of {len(filtype)} NL filaments generated.')

fracf = np.around(100*(NAf+NBf)/np.sum(NAf+NBf),2)
print(f'NL filament distribution: {fracf}.')

# CSK -------------------------------------------------------------------------
d1 = 10.2
h = 10.0
Nb  = [9, 12, 15, 18, 21, 24, 27, 30, 39, 43]
NMf = np.asarray([2, 8, 9, 6, 5, 4, 2, 1, 2, 2])*sclsq
NFf = np.asarray([3, 12, 15, 10, 10, 7, 5, 1, 2, 2])*sclsq
NFf = np.rint(NFf).astype(int)
NMf = np.rint(NMf).astype(int)

(filtype, filNb) = distrib(Nb,NMf,NFf,7,8)
(atoms2, bonds2, angles2, fil) = filaments(L-2.0,d1,h,filtype,filNb,
                                 natoms,nbonds,nangles,nmols)

natoms2 = np.shape(atoms2)[0]
nbonds2 = np.shape(bonds2)[0]
nangles2 = np.shape(angles2)[0]

natoms += natoms2
nbonds += nbonds2
nangles += nangles2
natomTs += 2 # FA, MT
nbondTs += 3 # FA, MT, OL
nangleTs += 2 # FA, MT
nmols += fil

print(f'{fil} of {len(filtype)} CSK filaments generated.')

fracf = np.around(100*(NFf+NMf)/np.sum(NFf+NMf),2)
print(f'CSK filament distribution: {fracf}.')

# PC --------------------------------------------------------------------------
natoms += 0
nbonds += 0
nangles += 0
natomTs += 2 # EC, HC
nbondTs += 1 # PC chain
nangleTs += 0
nmols += 0

# Write =======================================================================

with open('ne_csk.data','w') as fout:
    # Title comment -----------------------------------------------------------
    fout.write('Initial configuration of NE_CSK\n\n')

    # Header ------------------------------------------------------------------
    fout.write(f'{natoms} atoms\n')
    fout.write(f'{natomTs} atom types\n')
    fout.write(f'{nbonds} bonds\n')
    fout.write(f'{nbondTs} bond types\n')
    fout.write(f'{nangles} angles\n')
    fout.write(f'{nangleTs} angle types\n')
    fout.write(f'{nellipsoids} ellipsoids\n')
    fout.write('\n')

    # Box dimensions ----------------------------------------------------------
    fout.write('{} {} xlo xhi\n'.format(xlo, xhi))
    fout.write('{} {} ylo yhi\n'.format(ylo, yhi))
    fout.write('{} {} zlo zhi\n'.format(zlo, zhi))
    fout.write('\n')

    # Atoms section -----------------------------------------------------------
    fout.write('Atoms # hybrid\n\n')

    jadd = 1
    for j in range(natoms0):
        fout.write('{:.0f} {:.0f} {:.6f} {:.6f} {:.6f}'\
                   ' {:.0f} {:.4f} {:.0f} {:.0f} 0 0 0'\
                   '\n'.format(j+jadd,types0[j],*tuple(atoms0[j,:]),
                   ellipsoidflag0,density0[j],molecule_ID0,charge0))

    jadd += natoms0
    for j in range(natoms1):
        fout.write('{:.0f} {:.0f} {:.6f} {:.6f} {:.6f}'\
                   ' {:.0f} {:.4f} {:.0f} {:.0f} 0 0 0'\
                   '\n'.format(*tuple(atoms1[j,:])))

    jadd += natoms1
    for j in range(natoms2):
        fout.write('{:.0f} {:.0f} {:.6f} {:.6f} {:.6f}'\
                   ' {:.0f} {:.4f} {:.0f} {:.0f} 0 0 0'\
                   '\n'.format(*tuple(atoms2[j,:])))

    fout.write('\n')

    # Bonds section -----------------------------------------------------------
    fout.write('Bonds\n\n')

    jadd = 1
    for j in range(nbonds1):
        fout.write('{:.0f} {:.0f} {:.0f} {:.0f}'\
                   '\n'.format(*tuple(bonds1[j,:])))

    jadd += nbonds1
    for j in range(nbonds2):
        fout.write('{:.0f} {:.0f} {:.0f} {:.0f}'\
                   '\n'.format(*tuple(bonds2[j,:])))

    fout.write('\n')

    # Angles section ----------------------------------------------------------
    fout.write('Angles\n\n')

    jadd = 1
    for j in range(nangles1):
        fout.write('{:.0f} {:.0f} {:.0f} {:.0f} {:.0f}'\
                   '\n'.format(*tuple(angles1[j,:])))

    jadd += nangles1
    for j in range(nangles2):
        fout.write('{:.0f} {:.0f} {:.0f} {:.0f} {:.0f}'\
                   '\n'.format(*tuple(angles2[j,:])))

    fout.write('\n')

    # Ellipsoids section ------------------------------------------------------
    fout.write('Ellipsoids\n\n');

    jadd = 1
    for j in range(natoms0):
            fout.write('{:.0f} {:.2f} {:.2f} {:.2f} {:.6f} '\
                       '{:.6f} {:.6f} {:.6f}\n'.format(j+jadd,
                       *tuple(shape0),*tuple(quat[:])))

    fout.write('\n')

print('ne_csk.data generated.')

# Exit ========================================================================
sys.exit()
