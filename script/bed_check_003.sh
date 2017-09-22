#!/bin/bash
echo "bsim command check"
echo "./clean.sh"
./clean.sh
echo "bsim -p project/dff.prj"
bsim -p project/dff.prj
if [ $? == 0 ]; then
    echo "---------- OK"
else
    echo "---------- NG"
fi
echo ""
echo "bsim -t tb/dff_top.sv test/bed_test/tc001"
bsim -t tb/dff_s2cif_top.sv test/bed_test/tc001
if [ $? == 0 ]; then
    echo "---------- OK"
else
    echo "---------- NG"
fi
echo ""
echo "bsim test/bed_test/tc001"
bsim test/bed_test/tc001
if [ $? == 0 ]; then
    echo "---------- OK"
else
    echo "---------- NG"
fi
echo ""



