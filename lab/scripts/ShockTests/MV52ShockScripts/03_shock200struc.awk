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
print  " MV 5.2 Shock Test 03: 200km/s Structure"
print  " Quantity      ,   MVS5,   Model,  Diff%"
printf(" TPre    kK    ,  9.605, %7.3f, %6.1f\n", tpr    , 100*(tpr    -  9.60500e+00)/ 9.60500e+00);
printf(" XHIPre 1E-3   ,  5.034, %7.3f, %6.1f\n", xhi    , 100*(xhi    -  5.03434e+00)/ 5.03434e+00);
printf(" TShock  kK    , 568.80, %7.2f, %6.1f\n", tin    , 100*(tin    -  5.68798e+02)/ 5.68798e+02);
printf(" Mach Number   , 13.666, %7.3f, %6.1f\n", Mach   , 100*(Mach   -  1.36660e+01)/ 1.36660e+01);
printf(" Alfven Mach   , 173.13, %7.2f, %6.1f\n", MachA  , 100*(MachA  -  1.73130e+02)/ 1.73130e+02);
printf(" R4   E17cm    ,  7.543, %7.3f, %6.1f\n", r4     , 100*(r4     -  7.54290e+00)/ 7.54290e+00);
printf(" R3   E17cm    ,  8.035, %7.3f, %6.1f\n", r3     , 100*(r3     -  8.03450e+00)/ 8.03450e+00);
printf(" nH post       ,  3.936, %7.3f, %6.1f\n", nh     , 100*(nh     -  3.93620e+00)/ 3.93620e+00);
printf(" nH4           , 163.39, %7.2f, %6.1f\n", n4     , 100*(n4     -  1.63390e+02)/ 1.63390e+02);
printf(" nH3           , 215.65, %7.2f, %6.1f\n", n3     , 100*(n3     -  2.15650e+02)/ 2.15650e+02);
}
