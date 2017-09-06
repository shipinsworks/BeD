#!/bin/bash
echo "bsim command check"
echo "./clean.sh"
./clean.sh
echo "bsim -p dff.prj -t tb/dff_top.sv => OK"
bsim -p dff.prj -t tb/dff_top.sv
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
