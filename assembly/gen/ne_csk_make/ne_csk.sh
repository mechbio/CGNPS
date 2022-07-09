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
# This file (ne_csk.sh) is for generating ne_csk.data.
# -----------------------------------------------------------------------------

# date         :10-Apr-22
# version      :0.7.0
# usage        :./ne_csk.sh
# sh_version   :4.2.46(2)-release

# Run ne_csk.py
python3 ne_csk.py 2.5

# copy to data
mkdir -p ../../data/
mv ne_csk.data ../../data/

exit 0
