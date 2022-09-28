#!/bin/tcsh
# v1.0.7
# tcsh for timing format
#
set exe="map51"
set scr=${1}
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
#
(time /usr/local/bin/${exe} < ${scr} >map5output.txt) | awk '{print " "$1" "$2" "$3" "$4}' >> timing.txt
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
