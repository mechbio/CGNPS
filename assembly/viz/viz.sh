#!/bin/bash
# -*- coding: utf-8 -*-

# CGNPS - Coarse-Grained Nuclear Periphery Simulator
#
# See the README file in the top-level CGNPS directory.
# This software is released under the GNU General Public License.

# -----------------------------------------------------------------------------
# This file (viz.sh) is used to process data for visualization with OVITO.
# -----------------------------------------------------------------------------

# date         :30-Feb-22
# version      :0.6.0
# usage        :./viz.sh
# sh_version   :4.2.46(2)-release

# Go to data
cd ../data

# Remove portion that is not handled in ovito-basic-3.3.5
sed -n '/Ellipsoids/q;p' < combined.data > combined2.data
sed -n '/Ellipsoids/q;p' < init.data > init2.data

# Return to pwd
cd ../viz

exit 0
