#
# v1.0.12
#
BEGIN{fq=0;pq=0;sl=1;}
/v_shock/{v=$3}
/Velocity       :/{v=$3}
/Q_ions/{q=$3}
/Q\/v/{psi=$3}
/Proto Mag Alpha /{alpha0=$5}
/Preshock Mag Alpha /{alpha=$5}
/Preshock     B :/{b=$4}
/Preshock Mach Number/{mach=$5}
/Preshock Alfven Mach Number/{amach=$6}
/Preshock     T :/{tpc=$4}
/Preshock     nH:/{nhp=$3}
/Preshock     mu:/{mu=$3}
/Preshock    FHI:/{fhis=$3}
/Preshock   FHII:/{fhiis=$3}
/Preshock   FHeI:/{fheis=$3}
/Preshock  FHeII:/{fheiis=$3}
/Preshock FHeIII:/{fheiiis=$3}
/Postshock    T :/{tps=$4}
/Postshock Compression/{cmpf=$5}
/ d6:/{dist6=$2}
/ d5:/{dist5=$2}
/ d4:/{dist4=$2}
/ d3:/{dist3=$2}
/Step <Te>/{pq=1}
((/^   1 /)&&(pq==1)){t=$2;fhi=$8}
/Output created/{pq=0}
END{
rp=nhp*v*v;
printf("  %7.3f,  %7.3f,  %7.3f,  %7.3f,  %8.4e,  %8.4e, %7.3f,  %7.3f,  %7.3f,  %8.4e, %8.4e, %8.4e, %8.4e, %8.4e, %8.4e, %8.4e, %8.4e, %7.3f, %8.4e, %8.4e, %8.4e, %8.4e, %8.4e, P6:,  %7.3f,  %8.4e\n",
          v,alpha0,alpha,b,nhp,rp,tps,mach,amach,cmpf,dist6,dist5,dist4,dist3,q,psi,mu,tpc,fhis,fhiis,fheis,fheiis,fheiiis,t,fhi);
}
