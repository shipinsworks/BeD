#!/bin/bash
rm -f *.log
rm -f *.jou
rm -f *.pb
rm -fr xsim.dir
find . -name "*~" | xargs rm -f
find . -name "sim_*" -type d | xargs rm -fr
