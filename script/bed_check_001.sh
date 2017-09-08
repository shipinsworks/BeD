#!/bin/bash
echo "bsim command check"
echo "./clean.sh"
./clean.sh
echo "bsim -p dff.prj"
bsim -p dff.prj
if [ $? == 0 ]; then
    echo "---------- OK"
else
    echo "---------- NG"
fi
echo ""
echo "bsim -t tb/dff_top.sv"
bsim -t tb/dff_s2cif_top.sv
if [ $? == 0 ]; then
    echo "---------- OK"
else
    echo "---------- NG"
fi
echo ""
echo "bsim testcase/bed_testcase/tc001 => Error: not run xelab"
bsim testcase/bed_testcase/tc001
if [ $? != 0 ]; then
    echo "---------- OK"
else
    echo "---------- NG"
fi
echo ""
