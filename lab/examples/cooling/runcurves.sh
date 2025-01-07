#!/bin/bash
# v5.2.1 v2.0.1
# bash version
# uses POSIX /usr/bin/time -h 2>&1  instead of builtin to avoid shell dependence
#
TIMEFORMAT="%R real %U user %S sys %P cpu%%"
d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
exe="$HOME/mappings520/bin/map52"
#
echo " MV 5.2.1 Curve Tests: Clearing Area ..."
rm -f timing.txt map5output.txt
rm -f *.csv *.neq *.cie *.pie
echo " MV 5.2.1 Test 1: NEQ cooling 3 < logT < 9 ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOSTNAME" >> timing.txt
(time $exe < neq_sol.mv >map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "MVCtest_$d.txt"
cat timing.txt
echo " MV 5.2.1 Test 2: PIE 3 < logQH < 15 ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOSTNAME" >> timing.txt
(time  $exe < pie_sol.mv >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "MVCtest_$d.txt"
cat timing.txt
echo " MV 5.2.1 Test 3: CIE 2 < logT < 9 ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOSTNAME" >> timing.txt
(time  $exe < cie_sol.mv >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "MVCtest_$d.txt"
cat timing.txt
echo " MV 5.2.1 Curve Tests completed."
rm -f timing.txt map5output.txt
rm -f *.csv *.neq *.cie *.pie
