#!/bin/tcsh
# v5.1.21
# tcsh for timing format and $HOST (instead of $HOSTNAME for bash)
#
set d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
set r='MV52Results'
set s='MV52Scripts'
set i="MV52Inputs"
set mexe="${HOME}/mappings520/bin/map52"
#
echo " MV 5.2 Tests: Clearing Area ..."
rm -f timing.txt map5output.txt
rm -f *.ph6 *.nfn *.lam v*.sou *.bln *.sh5 *.csv SH*.csv PC*.csv
#
echo " MV 5.2 Test 1: Solar HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/01_solhii.mv" >map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/01_solhii.awk" photn0001.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/01_solhii.awk" photn0001.ph6
#
echo " MV 5.2 Test 2: Primordial HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/02_primhii.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/02_primordial.awk" photn0002.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/02_primordial.awk" photn0002.ph6
#
echo " MV 5.2 Test 3: Test Solar Z 100kK PN ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/03_testpn2.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/03_testpn2.awk" photn0003.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/03_testpn2.awk" photn0003.ph6
#
echo " MV 5.2 Test 4: Dusty Isobaric Low Z HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/04_dustyhii.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/04_dustyhii.awk" photn0004.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/04_dustyhii.awk" photn0004.ph6
#
echo " MV 5.2 Test 5: Dusty Isobaric PAH HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time "${mexe}" < "$s/05_dustypah.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/05_dustypah.awk" photn0005.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/05_dustypah.awk" photn0005.ph6
#
echo " MV 5.2 Tests completed. Output in "$r/MV52test_$d.txt""
rm -f timing.txt map5output.txt
rm -f *.ph6 *.nfn *.lam v*.sou *.bln *.sh5 *.csv SH*.sou PC*.sou
