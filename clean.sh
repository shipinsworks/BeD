#!/bin/bash
rm -f *.log
rm -f *.jou
rm -f *.pb
rm -fr xsim.dir
rm -f vivado_pid*.zip
find . -name "*~" | xargs rm -f
find . -name "sim*" -type d | xargs rm -fr
