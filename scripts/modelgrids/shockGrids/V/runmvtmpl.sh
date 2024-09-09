#!/bin/bash
# v5.2.0 v2.0.2
# bash version
# uses POSIX /usr/bin/time -p 2>&1  instead of builtin to avoid shell dependence
#
scr=${1}
date | awk '{print " "$0}' > timing.txt
echo " $HOSTNAME" >> timing.txt
#
echo "MPATH/MEXE" >> timing.txt
echo "${scr}" >> timing.txt
#
( /usr/bin/time -p 2>&1 "MPATH/MEXE" < "${scr}" > map5output.txt ) | awk '/real/{rl=1.0*$2};/user/{ul=1.0*$2};/sys/{sl=1.0*$2};END{printf(" %.2fu %.2fs %.2fw %.2f%%\n",ul,sl,rl,(100.0*ul)/(ul+sl))}'>> timing.txt
cat timing.txt
#
sed "s/\.-/. -/g" map5output.txt > shock5output.txt
mkdir "precursor"
mv *p0001.bln precursor/
mv *pc_up* precursor/
cp *pcspec* precursor/
mv *.ph6 precursor/
mv spec0001.csv precursor/
#
#rm -f timing.txt map5output.txt
#
