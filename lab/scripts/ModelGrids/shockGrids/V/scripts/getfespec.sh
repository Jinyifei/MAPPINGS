#!/bin/bash
#
# v1.0.10
#
# use:  ./getgrid.sh V[012]*
#
vers="v5.2.0"
#
date
echo "MV ${vers} S5 Shock Grid Iron Spectral Lines"
echo "V[1],\
Alpha0[2],\
Alpha[3],\
B(microG)[4],\
Mach[5],\
AMach[6],\
nH[7],\
RP[8],\
HBeta[9],\
FeV3756[10],\
FeV3783[11],\
FeV3795[12],\
FeV3839[13],\
FeV3891[14],\
FeV3895[15],\
FeV4071[16],\
FeV4143[17],\
FeV4181[18],\
FeV4227[19],\
FeIII4658[20],\
FeIII4702[21],\
FeIII4734[22],\
FeIII4755[23],\
FeIII4769[24],\
FeIII4881[25],\
FeIV4907[26],\
FeVI4972[26],\
FeIII4986[28],\
FeIII4987[29],\
FeIII5011[30],\
FeVI5146[31],\
FeII5159[32],\
FeVI5176[33],\
FeII5262[34],\
FeIII5270[35],\
FeIV6734[36],\
FeIV6740[37],\
NiII7378[38],\
FeII8617[39],\
FeII8892[40],\
FeII9052[41],\
FeII9227[42]"
#
for i
do
awk -f lines_fespec.awk $i/v*_spec0001.csv
done
