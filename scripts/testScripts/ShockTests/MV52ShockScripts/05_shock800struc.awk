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
/Preshock    XHI:/{xhi = 1e4*$3}
/Postshock    T :/{tin = 1e-6*$4}
/Postshock    nH:/{nh = $3}
/      d4:,/{r4 = 1e-19*$2}
/     nH4:,/{n4 = $2}
/      d3:,/{r3 = 1e-19*$2}
/     nH3:,/{n3 = $2}
/ Mass  X,/ {lineion = NR}
(/^ II  /&&(lineion>0)){h2 = $2; he2 = $3; lineion = 0}
/ Average ionic temperatures/ {lineth = NR}
(/^ II   /&&(lineth>0)) {th = $2; lineth = 0}

END{
print  " MV Shock Test 05: 800km/s Structure"
print  " Quantity      ,   MVS5,   Model,  Diff%"
printf(" TPre    kK    , 23.384, %7.3f, %6.1f\n", tpr   , 100*(tpr    -  2.33840e+01)/ 2.33840e+01);
printf(" XHIPre 1E-4   ,  2.952, %7.3f, %6.1f\n", xhi   , 100*(xhi    -  2.95210e+00)/ 2.95210e+00);
printf(" TShock  MK    ,  8.752, %7.3f, %6.1f\n", tin   , 100*(tin    -  8.75154e+00)/ 8.75154e+00);
printf(" Mach Number   , 34.566, %7.3f, %6.1f\n", Mach  , 100*(Mach   -  3.45660e+01)/ 3.45660e+01);
printf(" Alfven Mach   , 692.52, %7.2f, %6.1f\n", MachA , 100*(MachA  -  6.92520e+02)/ 6.92520e+02);
printf(" R4   E19cm    , 27.551, %7.3f, %6.1f\n", r4    , 100*(r4     -  2.75511e+01)/ 2.75511e+01);
printf(" R3   E19cm    , 27.576, %7.3f, %6.1f\n", r3    , 100*(r3     -  2.75759e+01)/ 2.75759e+01);
printf(" nH post       ,  3.990, %7.3f, %6.1f\n", nh    , 100*(nh     -  3.98990e+00)/ 3.98990e+00);
printf(" nH4           , 876.87, %7.2f, %6.1f\n", n4    , 100*(n4     -  8.76870e+02)/ 8.76870e+02);
printf(" nH3           , 926.49, %7.2f, %6.1f\n", n3    , 100*(n3     -  9.26490e+02)/ 9.26490e+02);
}
