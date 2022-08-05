#!/bin/bash
#
# drop in replacement grid for compSED
# uses old scaling and normalisation
#
m0="1e6"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="2e6"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="3e6"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="4e6"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="5e6"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="1e7"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="2e7"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="3e7"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="5e7"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="1e8"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="2e8"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="3e8"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="5e8"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
m0="1e9"
l0="0.01"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.02"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.03"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.05"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.10"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.20"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.30"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="0.50"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
l0="1.00"
#
# make the conf and run it
#
sed -e s/BHMASS/${m0}/g \
    -e s/LOLEDD/${l0}/g \
    agn-blstemplate.conf > agn.conf
outfile="M"${m0}"_E"${l0}"_BLS1.txt"
echo ${outfile}
./agn > ${outfile}
#
echo "done!"
