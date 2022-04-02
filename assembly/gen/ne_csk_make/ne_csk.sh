#!/bin/bash
# -*- coding: utf-8 -*-

# CGNPS - Coarse-Grained Nuclear Periphery Simulator
#
# See the README file in the top-level CGNPS directory.
# This software is released under the GNU General Public License.

# -----------------------------------------------------------------------------
# This file (ne_csk.sh) is for generating ne_csk.data.
# -----------------------------------------------------------------------------

# date         :08-Jan-22
# version      :0.6.0
# usage        :./ne_csk.sh
# sh_version   :4.2.46(2)-release

# Run ne_csk.py
python3 ne_csk.py 2.5

# copy to data
mv ne_csk.data ../../data/

exit 0
