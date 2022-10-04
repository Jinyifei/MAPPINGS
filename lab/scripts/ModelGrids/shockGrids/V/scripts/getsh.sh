#!/bin/bash
# v1.0.12
#
# use:  ./getsh.sh V[012]*
#
d=$(date "+%s" | awk '{print substr(sprintf("%X",$0),3,6)}')
echo " "
date

# MAPPINGS version
#
vers="v5.2.0"
#
echo " MV ${vers} S5 Shock Grid."
#
# Collect all the outputs into a global csv, extracting
# from sub directories in order....
#
echo " Vs[1],   Alpha0[2],     Alpha[3],      B[4],\
       nH[5],       RP[6],        Ts[7],   Mach[8],   AMach[9],\
    CMPF[10],      D6[11],       D5[12],      D4[13],       D3[14],\
      Qs[15],     Psi[16],      mu0[17],      T0[18],\
     FHI[19],    FHII[20],\
    FHeI[21],   FHeII[22],   FHeIII[23],\
    [24],         Teq[25],    FHIeq[26] "
#
# collect data into one csv...
#
for i
do
    awk -f shocks.awk $i/shock5output.txt
done
echo " "
