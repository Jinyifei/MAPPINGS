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
/Postshock    T :/{tin = 1e-6*$4}
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
print  " MV Shock Test 04: 400km/s Structure"
print  " Quantity      ,   MVS5,   Model,  Diff%"
printf(" TPre    kK    , 12.971, %7.3f, %6.1f\n", tpr    , 100*(tpr    -  1.29710e+01)/ 1.29710e+01);
printf(" XHIPre 1E-3   ,  1.399, %7.3f, %6.1f\n", xhi    , 100*(xhi    -  1.39885e+00)/ 1.39885e+00);
printf(" TShock  MK    ,  2.199, %7.3f, %6.1f\n", tin    , 100*(tin    -  2.19908e+00)/ 2.19908e+00);
printf(" Mach Number   , 23.233, %7.3f, %6.1f\n", Mach   , 100*(Mach   -  2.32330e+01)/ 2.32330e+01);
printf(" Alfven Mach   , 346.26, %7.2f, %6.1f\n", MachA  , 100*(MachA  -  3.46260e+02)/ 3.46260e+02);
printf(" R4   E17cm    , 116.16, %7.2f, %6.1f\n", r4     , 100*(r4     -  1.16156e+02)/ 1.16156e+02);
printf(" R3   E17cm    , 117.00, %7.2f, %6.1f\n", r3     , 100*(r3     -  1.17000e+02)/ 1.17000e+02);
printf(" nH post       ,  3.978, %7.3f, %6.1f\n", nh     , 100*(nh     -  3.97770e+00)/ 3.97770e+00);
printf(" nH4           , 393.31, %7.2f, %6.1f\n", n4     , 100*(n4     -  3.93310e+02)/ 3.93310e+02);
printf(" nH3           , 445.02, %7.2f, %6.1f\n", n3     , 100*(n3     -  4.45020e+02)/ 4.45020e+02);
}
