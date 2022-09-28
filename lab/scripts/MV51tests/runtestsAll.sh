#!/bin/tcsh
# v5.1.21dev
# tcsh for timing format and $HOST (instead of $HOSTNAME for bash)
#
set d=`(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')`
set r='MV51Results'
set s='MV51Scripts'
set i="MV51Inputs"
set exe="map51dev"
#
echo " MV 5.1 Tests: Clearing Area ..."
cp "data/PHOTDAT.txt" "$i/PHOTDAT_prev.txt"
cp "$i/PHOTDAT-51.txt" "data/PHOTDAT.txt"
rm -f timing.txt map5output.txt
rm -f *.ph6 *.nfn *.lam v*.sou *.bln *.sh5 *.csv SH*.csv PC*.csv
echo " MV 5.1 Test 1: Solar HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time ./$exe < "$s/01_solhii.mv" >map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/01_solhii.awk" photn0001.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/01_solhii.awk" photn0001.ph6
echo " MV 5.1 Test 2: Primordial HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time ./$exe < "$s/02_primhii.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/02_primordial.awk" photn0002.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/02_primordial.awk" photn0002.ph6
echo " MV 5.1 Test 3: Test Solar Z 100kK PN ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time ./$exe < "$s/03_testpn2.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/03_testpn2.awk" photn0003.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/03_testpn2.awk" photn0003.ph6
echo " MV 5.1 Test 4: Dusty Isobaric Low Z HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time ./$exe < "$s/04_dustyhii.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/04_dustyhii.awk" photn0004.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/04_dustyhii.awk" photn0004.ph6
echo " MV 5.1 Test 5: Dusty Isobaric PAH HII region ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" >> timing.txt
(time ./$exe < "$s/05_dustypah.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/05_dustypah.awk" photn0005.ph6 >> "$r/MV52test_$d.txt"
awk -f "$s/05_dustypah.awk" photn0005.ph6
echo " MV 5.1 Test 6: 200 km/s iterative shock ..."
date | awk '{print " "$0}' > timing.txt
echo " $HOST" > timing.txt
(time ./$exe < "$s/06_shock200.mv" >>map5output.txt)| awk '{print " "$1" "$2" "$3" "$4}'>> timing.txt
cat timing.txt >> "$r/MV52test_$d.txt"
cat timing.txt
awk -f "$s/06_shock200spec.awk" specSHv200s_0001.csv >> "$r/MV52test_$d.txt"
awk -f "$s/06_shock200spec.awk" specSHv200s_0001.csv
awk -f "$s/06_shock200prec.awk" specPCv200s_0001.csv >> "$r/MV52test_$d.txt"
awk -f "$s/06_shock200prec.awk" specPCv200s_0001.csv
awk -f "$s/06_shock200struc.awk" shck_v200s_0001.sh5 >> "$r/MV52test_$d.txt"
awk -f "$s/06_shock200struc.awk" shck_v200s_0001.sh5
echo " MV 5.1 Tests completed. Output in "$r/MV52test_$d.txt""
rm -f timing.txt map5output.txt
rm -f *.ph6 *.nfn *.lam v*.sou *.bln *.sh5 *.csv SH*.sou PC*.sou
mv "$i/PHOTDAT_prev.txt" "data/PHOTDAT.txt"
