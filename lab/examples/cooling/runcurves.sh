#!/bin/bash
# v5.2.0 v2.0.1
# bash version
# uses POSIX /usr/bin/time -h 2>&1  instead of builtin to avoid shell dependence
#
d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
mexe="${HOME}/mappings520/bin/map52"
#
echo " MV 5.2.0 Curve Tests: Clearing Area ..."
rm -f timing.txt map5output.txt
rm -f *.csv *.neq *.cie *.pie
echo " MV 5.2.0 Test 1: NEQ cooling 3 < logT < 9 ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOSTNAME" >> timing.txt
( /usr/bin/time -h 2>&1 "${mexe}" < neq_sol.mv >map5output.txt) timing.txt
cat timing.txt >> "MVCtest_$d.txt"
cat timing.txt
echo " MV 5.2.0 Test 2: PIE 3 < logQH < 15 ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOSTNAME" >> timing.txt
( /usr/bin/time -h 2>&1 "${mexe}" < pie_sol.mv >>map5output.txt) timing.txt
cat timing.txt >> "MVCtest_$d.txt"
cat timing.txt
echo " MV 5.2.0 Test 3: CIE 2 < logT < 9 ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOSTNAME" >> timing.txt
( /usr/bin/time -h 2>&1 "${mexe}" < cie_sol.mv >>map5output.txt) >> timing.txt
cat timing.txt >> "MVCtest_$d.txt"
cat timing.txt
echo " MV 5.2.0 Curve Tests completed."
rm -f timing.txt map5output.txt
rm -f *.csv *.neq *.cie *.pie
