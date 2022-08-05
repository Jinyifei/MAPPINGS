#
# v5.1.20
#
BEGIN{line = 0;
  lineion= 0;
  h2 = 1.0; he2 = 0.0;
  lineth = 0;
  th    = 0.0;
  liner = 0;
  rout = 0.0;
  hbeta = 0.0
  hei5876  = 0.0;
  heii4686 = 0.0;
  ciii1909 = 0.0;
  civ1549  = 0.0;
  oiii5007 = 0.0;
  oiii518m = 0.0;
  oiv26m   = 0.0;
  neiii155m = 0.0;
  neiii3869 = 0.0;
  neiv2423  = 0.0;
  siii9532 = 0.0;
  siv105m  = 0.0;
}
/MAPPINGS V /{print " MAPPINGS V "$6}
/#    <Te>/{line = NR+1}
(NR==line){tin = $2; line = 0}
/Model ended/{liner = NR+1}
(NR==liner){rout = $3}
/ Mass  X,/ {lineion = NR}
(/^ II /&&(lineion>0)){h2 = $2; he2 = $3; lineion = 0}
/ Average ionic temperatures/ {lineth = NR+4}
(/^ II /&&(lineth>0)){th = $2; lineth = 0}
/H-beta  :,/ { n = split($0, a, ","); hbeta = a[4]}
/1548.187/ {n = split($0, a, ","); civ1549   = a[3]}
/1550.772/ {n = split($0, a, ","); civ1549   = civ1549 + a[3]}
/1906.683/ {n = split($0, a, ","); ciii1909  = a[3]}
/1908.734/ {n = split($0, a, ","); ciii1909  = ciii1909 + a[3]}
/2421.810/ {n = split($0, a, ","); neiv2423  = a[3]}
/2424.422/ {n = split($0, a, ","); neiv2423  = neiv2423 + a[3]}
/3868.764/ {n = split($0, a, ","); neiii3869 = a[3]}
/3967.471/ {n = split($0, a, ","); neiii3869 = neiii3869 + a[3]}
/4685.702/ {n = split($0, a, ","); heii4686  = a[3]}
/4958.911/ {n = split($0, a, ","); oiii5007  = a[3]}
/5006.843/ {n = split($0, a, ","); oiii5007  = oiii5007+a[3]}
/5875.664/ {n = split($0, a, ","); hei5876   = a[3]}
/9068.620/ {n = split($0, a, ","); siii9532  = a[3]}
/9530.619/ {n = split($0, a, ","); siii9532  = siii9532 + a[3]}
/105104.947/ {n = split($0, a, ","); siv105m   = a[3]}
/155550.993/ {n = split($0, a, ","); neiii155m = a[3]}
/258933.195/ {n = split($0, a, ","); oiv26m    = a[3]}
/518145.454/ {n = split($0, a, ","); oiii518m  = a[3]}
/Detailed Emission Spectrum/{
print " Table 7 Kentucky Benchmark Nebulae"
print " Lo Ionisation High Density 75kK PN"
hb = hbeta*1.0e-34
print  " Quantity     ,  Mean,   Model,  Diff%";
printf(" HBeta   E34  ,  5.41, %7.3f, %6.1f\n", hb       , 100*(hb       - 5.41 )/ 5.41);
printf(" HeI     5876 ,  0.13, %7.3f, %6.1f\n", hei5876  , 100*(hei5876  - 0.13 )/ 0.13);
printf(" HeII    4686 , 0.088, %7.3f, %6.1f\n", heii4686 , 100*(heii4686 -0.088 )/0.088);
printf(" CIII]   1909+,  1.17, %7.3f, %6.1f\n", ciii1909 , 100*(ciii1909 - 1.17 )/ 1.17);
printf(" CIV     1549+,  1.38, %7.3f, %6.1f\n", civ1549  , 100*(civ1549  - 1.38 )/ 1.38);
printf(" [OIII]  5007+, 14.30, %7.3f, %6.1f\n", oiii5007 , 100*(oiii5007 -14.30 )/14.30);
printf(" [OIII]  51.8m,  0.26, %7.3f, %6.1f\n", oiii518m , 100*(oiii518m - 0.26 )/ 0.26);
printf(" [OIV]   26m  ,  0.22, %7.3f, %6.1f\n", oiv26m   , 100*(oiv26m   - 0.22 )/ 0.22);
printf(" [NeIII] 15.5m,  1.11, %7.3f, %6.1f\n", neiii155m, 100*(neiii155m- 1.11 )/ 1.11);
printf(" [NeIII] 3869+,  1.44, %7.3f, %6.1f\n", neiii3869, 100*(neiii3869- 1.44 )/ 1.44);
printf(" [NeIV]  2423+,  0.10, %7.3f, %6.1f\n", neiv2423 , 100*(neiv2423 - 0.10 )/ 0.10);
printf(" [SIII]  9532+,  0.52, %7.3f, %6.1f\n", siii9532 , 100*(siii9532 - 0.52 )/ 0.52);
printf(" [SIV]   10.5m,  1.43, %7.3f, %6.1f\n", siv105m  , 100*(siv105m  - 1.43 )/ 1.43);
suml =      (hei5876+heii4686+ciii1909+civ1549)
suml = suml+(oiii5007+oiii518m+oiv26m)
suml = suml+(neiii155m+neiii3869+neiv2423)
suml = suml+(siii9532+siv105m)
suml = suml*hb   ;
tin  = tin*1.0e-4;
th   = th *1.0e-4;
printf(" Ltot    E34  ,  120., %7.2f, %6.1f\n", suml   , 100*(suml  -  120)/  120);
printf(" Tinner  K  E4,  1.78, %7.3f, %6.1f\n", tin    , 100*(tin   - 1.78)/ 1.78);
printf(" Th+     K  E4,  1.16, %7.3f, %6.1f\n", th     , 100*(th    - 1.16)/ 1.16);
printf(" <He+>/<H+>   , 0.910, %7.3f, %6.1f\n\n", he2/h2 , 100*((he2/h2)-0.910)/0.910);
}
