#
# v5.2.0
#
BEGIN{line = 0;
  lineion  = 0;
  lineth   = 0;
  h2 = 1.0; he2 = 0.0;
  tpr       = 0.0;
  tin       = 0.0;
  Mach      = 0.0;
  MachA     = 0.0;
  tin       = 0.0;
  dist4     = 0;
  dist3     = 0;
  r4        = 0.0;
  r3        = 0.0;
}
/Preshock Mach Number/{Mach = $5}
/Preshock Alfven Mach/{MachA = $6}
/Preshock     T :/{tpr = 1e-3*$4}
/Preshock    XHI:/{xhi = 1e3*$3}
/Postshock    T :/{tin = 1e-3*$4}
/Postshock    nH:/{nh = $3}
/      d4:,/{r4 = 1e-17*$2}
/     nH4:,/{n4 = $2}
/      d3:,/{r3 = 1e-17*$2}
/     nH3:,/{n3 = $2}
/ Mass  X,/ {lineion = NR}
(/^ II  /&&(lineion>0)){h2 = $2; he2 = $3; lineion = 0}
/ Average ionic temperatures/ {lineth = NR}
(/^ II   /&&(lineth>0)) {th = $2; lineth = 0}

END{
print  " MV 5.1 S5 Test 06c 200km/s shock Structure Solar Metallicity"
print  " Quantity      ,   MVS5,   Model,  Diff%"
printf(" TPre    kK    ,  9.470, %7.3f, %6.1f\n", tpr    , 100*(tpr    -  9.47030)/ 9.47030);
printf(" XHIPre 1E-3   ,  4.960, %7.3f, %6.1f\n", xhi    , 100*(xhi    -  4.96015)/ 4.96015);
printf(" TShock  kK    , 568.19, %7.2f, %6.1f\n", tin    , 100*(tin    -  568.188)/ 568.188);
printf(" Mach Number   , 13.756, %7.3f, %6.1f\n", Mach   , 100*(Mach   -  13.7560)/ 13.7560);
printf(" Alfven Mach   , 173.99, %7.2f, %6.1f\n", MachA  , 100*(MachA  -  173.990)/ 173.990);
printf(" R4   E17cm    ,  7.481, %7.3f, %6.1f\n", r4     , 100*(r4     -  7.48079)/ 7.48079);
printf(" R3   E17cm    ,  7.969, %7.3f, %6.1f\n", r3     , 100*(r3     -  7.96879)/ 7.96879);
printf(" nH post       ,  3.937, %7.3f, %6.1f\n", nh     , 100*(nh     -  3.93700)/ 3.93700);
printf(" nH4           , 162.71, %7.2f, %6.1f\n", n4     , 100*(n4     -  162.710)/ 162.710);
printf(" nH3           , 216.34, %7.2f, %6.1f\n", n3     , 100*(n3     -  216.340)/ 216.340);
}
