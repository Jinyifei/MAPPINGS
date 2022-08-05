#!/bin/tcsh
# v5.1.20
# tcsh for timing format and $HOST (instead of $HOSTNAME for bash)
#
set d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
#
echo " MV 5.1.20 Curve Tests: Clearing Area ..."
rm -f timing.txt map5output.txt
rm -f *.csv *.neq *.cie *.pie
echo " MV 5.1.20 Test 1: NEQ cooling 3 < logT < 9 ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time ./map51 < neq_sol.mv >map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "MVCtest_$d.txt"
cat timing.txt
echo " MV 5.1.20 Test 2: PIE 3 < logQH < 15 ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time ./map51 < pie_sol.mv >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "MVCtest_$d.txt"
cat timing.txt
echo " MV 5.1.20 Test 3: CIE 2 < logT < 9 ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time ./map51 < cie_sol.mv >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "MVCtest_$d.txt"
cat timing.txt
echo " MV 5.1.20 Curve Tests completed."
rm -f timing.txt map5output.txt
rm -f *.csv *.neq *.cie *.pie
