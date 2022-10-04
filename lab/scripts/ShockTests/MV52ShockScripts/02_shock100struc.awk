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
/Preshock    XHI:/{xhi =      $3}
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
print  " MV 5.2 Shock Test 02: 100km/s Structure"
print  " Quantity      ,   MVS5,   Model,  Diff%"
printf(" TPre    kK    , 13.968, %7.3f, %6.1f\n", tpr    , 100*(tpr    -  1.39680e+01)/ 1.39680e+01);
printf(" XHIPre        ,  0.671, %7.3f, %6.1f\n", xhi    , 100*(xhi    -  6.71270e-01)/ 6.71270e-01);
printf(" TShock  kK    , 225.53, %7.2f, %6.1f\n", tin    , 100*(tin    -  2.25529e+02)/ 2.25529e+02);
printf(" Mach Number   ,  6.995, %7.3f, %6.1f\n", Mach   , 100*(Mach   -  6.99450e+00)/ 6.99450e+00);
printf(" Alfven Mach   , 86.551, %7.2f, %6.1f\n", MachA  , 100*(MachA  -  8.65510e+01)/ 8.65510e+01);
printf(" R4   E17cm    ,  0.138, %7.3f, %6.1f\n", r4     , 100*(r4     -  1.37821e-01)/ 1.37821e-01);
printf(" R3   E17cm    ,  0.241, %7.3f, %6.1f\n", r3     , 100*(r3     -  2.40642e-01)/ 2.40642e-01);
printf(" nH post       ,  3.767, %7.3f, %6.1f\n", nh     , 100*(nh     -  3.76680e+00)/ 3.76680e+00);
printf(" nH4           , 76.208, %7.3f, %6.1f\n", n4     , 100*(n4     -  7.62080e+01)/ 7.62080e+01);
printf(" nH3           , 124.51, %7.2f, %6.1f\n", n3     , 100*(n3     -  1.24510e+02)/ 1.24510e+02);
}
