#!/bin/bash
#
# v1.0.12
#
# use:  ./getgrid.sh V[012]*
#
vers="v5.2.0"
#
date
echo " MV ${vers} S5 Shock Spectra"
echo " V[1],\
Alpha0[2],\
Alpha[3],\
B-microG[4],\
Mach[5],\
AMach[6],\
nH[7],\
RP[8],\
HBeta[9],\
H2P[10],\
HAlpha[11],\
HeI5876[12],\
HeII4686[13],\
[NI]5199:5200+[14],\
[NII]5755[15],\
[NII]6584[16],\
[NII]6548:84+[17],\
[OI]5577[18],\
[OI]6300[19],\
[OI]6300:64+[20],\
[OII]3726:29+[21],\
[OII]3726[22],\
[OII]3729[23],\
[OII]7325+[24],\
[OIII]4363[25],\
[OIII]5007[26],\
[OIII]4959:5007+[27],\
[NeIII]3869:3967+[28],\
[NeV]3345:3425+[29],\
MgI4567[30],\
[SII]6716:31+[31],\
[SII]6716[32],\
[SII]6731[33],\
[SII]4067:76+[34],\
[SIII]6312[35],\
[SIII]9530[36],\
[SIII]9068:9530+[37],\
[CaII]3934[38]"
#
for i
do
awk -f lines_spec.awk $i/specSHv*0001.csv
done
