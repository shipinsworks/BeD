#!/bin/bash
echo "bsim command check"
echo "./clean.sh"
./clean.sh
echo "bsim -p project/dff.prj -t tb/dff_top.sv => OK"
bsim -p project/dff.prj -t tb/dff_s2cif_top.sv
if [ $? == 0 ]; then
    echo "---------- OK"
else
    echo "---------- NG"
fi
echo ""
echo "bsim pattern/bed_test/tc001 => Error: not run xelab"
bsim pattern/bed_test/tc001
if [ $? != 0 ]; then
    echo "---------- OK"
else
    echo "---------- NG"
fi
echo ""
