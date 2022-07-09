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
# This file plots fluctuation spectra from NE morphology.
# -----------------------------------------------------------------------------

# date             :14-Mar-2022
# version          :0.7.0
# usage            :gnuplot spectra.gp
# gnuplot_version  :5.2.7

set term svg size 350,400 font "Arial,18"
# font "Times-Roman,22"
set output '../fig/spectra.svg'
set encoding utf8

# set key outside
set key box opaque at 170,8e-3
# set key size
set key font ",15"
#set key off

# Parameters
Lc = 6200.0 # contour length of nucleus
L = 250.0 # size of NE patch in the simulation

# Data
simfile = "../data/freq.dat"
expfile = "spectrum-exp.txt"
uq2a(x) = (Lc**2)*(L**2)*gam
uq2b(x) = 4*(pi**2)*e*(L**2)*x**2
uq2c(x) = 16*(pi**4)*c*((L/Lc)**2)*x**4
uq2(x) = (Lc/100)**2/(uq2a(x) + uq2b(x) + uq2c(x))

# Data bounds
qmin = 10
qmax = 200

# Fitting
q_exp = 70
set fit quiet
set fit logfile '/dev/null'
set xrange [qmin:q_exp] # fitting range
c = 40.0 # in kBT

# e = 0.02 # in kBT/sig2
# gam = 0 # in kBT/sig4
# fit uq2(x) expfile via e

e = 0.02 # in kBT/sig2
gam = 0.8/(L**2) # in kBT/sig4
fit uq2(x) expfile via e, gam

# Fitting output
e2LT = 0.0414 # kBT/sig2 to mN/m
gam2CS = 414000 # kBT/sig4 to MJ/m4

BM = real(sprintf("%.1E", c))
LT = real(sprintf("%.1E", e*e2LT))
CS = real(sprintf("%.1E", gam*gam2CS))

print "Bending modulus = ",BM," kBT"
print "Lateral tension = ",LT," mN/m"
print "Confinement stiffness = ",CS," MJ/m4"

# Axes
set xrange [qmin:qmax]
set yrange [1e-8:1e-2]
set format x "10^{%L}"
set format y "10^{%L}"
set logscale x 10
set logscale y 10
set xtics qmin,10,qmax
set ylabel 'Mean-squared amplitude <u_q^{2}> (μm^2)'
set xlabel 'Wavenumber, q'

# Labels
# uq2l(x) = (Lc/100)**2/(uq2a(x))
# uq2m(x) = (Lc/100)**2/(uq2b(x))
# uq2h(x) = (Lc/100)**2/(uq2c(x))
# arr1a = 0.75*uq2l(10)
# arr1b = 0.75*uq2l(14)
# arr2a = 2*uq2m(28)
# arr2b = 2*uq2m(40)
# arr3a = 3*uq2h(100)
# arr3b = 3*uq2h(180)
# set arrow 1 from 10,arr1a to 14,arr1b nohead front lc rgb "black"
# set arrow 2 from 28,arr2a to 40,arr2b nohead front lc rgb "black"
# set arrow 3 from 100,arr3a to 180,arr3b nohead front lc rgb "black"
# lab1 = 1.5*uq2l(14)
# lab2 = 5*uq2m(38)
# lab3 = 9*uq2h(140)
# set label "q^0" at 14,lab1 center
# set label "q^{-2}" at 38,lab2 center
# set label "q^{-4}" at 140,lab3 center

# Plot
plot expfile u 1:2 w p lw 4 pt 6 ps 0.75 \
     lc rgb 'gold' title 'Experiments', \
     simfile u (Lc/(L/$1)):($2*1e-4) w p lw 4 pt 12 ps 0.75 \
     lc rgb 'dark-green' title 'Simulation', \
     uq2(x) w l lw 1 lc rgb 'blue' title 'Theoretical'

quit
