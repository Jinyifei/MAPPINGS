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
print  " MV Shock Test 01: 50km/s Structure"
print  " Quantity      ,   MVS5,   Model,  Diff%"
printf(" TPre    kK    ,  9.638, %7.3f, %6.1f\n", tpr    , 100*(tpr    -  9.63750e+00)/ 9.63750e+00);
printf(" XHIPre        ,  0.987, %7.3f, %6.1f\n", xhi    , 100*(xhi    -  9.86850e-01)/ 9.86850e-01);
printf(" TShock  kK    , 78.147, %7.3f, %6.1f\n", tin    , 100*(tin    -  7.81470e+01)/ 7.81470e+01);
printf(" Mach Number   ,  4.822, %7.3f, %6.1f\n", Mach   , 100*(Mach   -  4.82170e+00)/ 4.82170e+00);
printf(" Alfven Mach   , 43.273, %7.3f, %6.1f\n", MachA  , 100*(MachA  -  4.32730e+01)/ 4.32730e+01);
printf(" R4   E17cm    ,  0.032, %7.3f, %6.1f\n", r4     , 100*(r4     -  3.19449e-02)/ 3.19449e-02);
printf(" R3   E17cm    ,  0.247, %7.3f, %6.1f\n", r3     , 100*(r3     -  2.47019e-01)/ 2.47019e-01);
printf(" nH post       ,  3.536, %7.3f, %6.1f\n", nh     , 100*(nh     -  3.53570e+00)/ 3.53570e+00);
printf(" nH4           , 29.254, %7.3f, %6.1f\n", n4     , 100*(n4     -  2.92540e+01)/ 2.92540e+01);
printf(" nH3           , 58.970, %7.3f, %6.1f\n", n3     , 100*(n3     -  5.89700e+01)/ 5.89700e+01);
}
