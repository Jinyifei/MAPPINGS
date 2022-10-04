#!/bin/tcsh
# v5.2.0 v2.1.1
# tcsh for timing format
#
set scr=${1}
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt

(time MEXE < ${scr} >map5output.txt) | awk '{print " "$1" "$2" "$3" "$4}' >> timing.txt
cat timing.txt

rm -f timing.txt map5output.txt
rm -f *.ph7
