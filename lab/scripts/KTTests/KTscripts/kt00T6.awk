#
# v5.1.21
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
  nii6584  = 0.0;
  niii57m  = 0.0;
  oii3727  = 0.0;
  oiii5007 = 0.0;
  oiii518m = 0.0;
  oiv26m   = 0.0;
  neiii155m = 0.0;
  neiii3869 = 0.0;
  mgii2798 = 0.0;
  sliii1892 = 0.0;
  siii187m = 0.0;
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
/1882.707/ {n = split($0, a, ","); sliii1892 = a[3]}
/1892.029/ {n = split($0, a, ","); sliii1892 = sliii1892 + a[3]}
/1906.683/ {n = split($0, a, ","); ciii1909  = a[3]}
/1908.734/ {n = split($0, a, ","); ciii1909  = ciii1909 + a[3]}
/2790.777/ {n = split($0, a, ","); mgii2798  = a[3]}
/2795.528/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/2797.930/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/2797.998/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/2802.705/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/3726.032/ {n = split($0, a, ","); oii3727 = a[3]}
/3728.815/ {n = split($0, a, ","); oii3727 = oii3727 + a[3]}
/3868.764/ {n = split($0, a, ","); neiii3869 = a[3]}
/3967.471/ {n = split($0, a, ","); neiii3869 = neiii3869 + a[3]}
/4685.702/ {n = split($0, a, ","); heii4686  = a[3]}
/4958.911/ {n = split($0, a, ","); oiii5007  = a[3]}
/5006.843/ {n = split($0, a, ","); oiii5007  = oiii5007+a[3]}
/5875.664/ {n = split($0, a, ","); hei5876   = a[3]}
/6548.052/ {n = split($0, a, ","); nii6584 = a[3]}
/6583.454/ {n = split($0, a, ","); nii6584 = nii6584 + a[3]}
/9068.620/ {n = split($0, a, ","); siii9532  = a[3]}
/9530.619/ {n = split($0, a, ","); siii9532  = siii9532 + a[3]}
/105104.947/ {n = split($0, a, ","); siv105m   = a[3]}
/155550.993/ {n = split($0, a, ","); neiii155m = a[3]}
/187129.250/ {n = split($0, a, ","); siii187m  = a[3]}
/258933.195/ {n = split($0, a, ","); oiv26m    = a[3]}
/518145.454/ {n = split($0, a, ","); oiii518m  = a[3]}
/573394.495/ {n = split($0, a, ","); niii57m   = a[3]}
/Detailed Emission Spectrum/{
print " Table 6 Kentucky Benchmark Nebulae"
print " Hi Ionisation Low Density 75kK PN"
hb = hbeta*1.0e-34
print  " Quantity     ,  Mean,   Model,  Diff%";
printf(" HBeta   E34  ,  5.85, %7.3f, %6.1f\n", hb        , 100*(hb       - 5.85 )/ 5.85);
printf(" HeI     5876 ,  0.12, %7.3f, %6.1f\n", hei5876   , 100*(hei5876  - 0.12 )/ 0.12);
printf(" HeII    4686 ,  0.08, %7.3f, %6.1f\n", heii4686  , 100*(heii4686 - 0.08 )/ 0.08);
printf(" CIII]   1909+,  0.83, %7.3f, %6.1f\n", ciii1909  , 100*(ciii1909 - 0.83 )/ 0.83);
printf(" CIV     1549+,  0.34, %7.3f, %6.1f\n", civ1549   , 100*(civ1549  - 0.34 )/ 0.34);
printf(" [NII]   6584+,  0.12, %7.3f, %6.1f\n", nii6584   , 100*(nii6584  - 0.12 )/ 0.12);
printf(" [NIII]  57m  ,  0.39, %7.3f, %6.1f\n", niii57m   , 100*(niii57m  - 0.39 )/ 0.39);
printf(" [OII]   3727+,  0.29, %7.3f, %6.1f\n", oii3727   , 100*(oii3727  - 0.29 )/ 0.29);
printf(" [OIII]  5007+, 11.50, %7.3f, %6.1f\n", oiii5007  , 100*(oiii5007 - 11.50)/11.50);
printf(" [OIII]  51.8m,  2.02, %7.3f, %6.1f\n", oiii518m  , 100*(oiii518m - 2.02 )/ 2.02);
printf(" [OIV]   26m  ,  0.79, %7.3f, %6.1f\n", oiv26m    , 100*(oiv26m   - 0.79 )/ 0.79);
printf(" [NeIII] 15.5m,  1.35, %7.3f, %6.1f\n", neiii155m , 100*(neiii155m- 1.35 )/ 1.35);
printf(" [NeIII] 3869+,  1.03, %7.3f, %6.1f\n", neiii3869 , 100*(neiii3869- 1.03 )/ 1.03);
printf(" [MgII]  2798+,  0.13, %7.3f, %6.1f\n", mgii2798  , 100*(mgii2798 - 0.13 )/ 0.13);
printf(" [SiIII] 1892+,  0.15, %7.3f, %6.1f\n", sliii1892 , 100*(sliii1892- 0.15 )/ 0.15);
printf(" [SIII]  18.7m,  0.34, %7.3f, %6.1f\n", siii187m  , 100*(siii187m - 0.34 )/ 0.34);
printf(" [SIII]  9532+,  1.13, %7.3f, %6.1f\n", siii9532  , 100*(siii9532 - 1.13 )/ 1.13);
printf(" [SIV]   10.5m,  2.05, %7.3f, %6.1f\n", siv105m   , 100*(siv105m  - 2.05 )/ 2.05);
suml =      (hei5876+heii4686+ciii1909+civ1549+nii6584)
suml = suml+(niii57m+oii3727+oiii5007+oiii518m+oiv26m)
suml = suml+(neiii155m+neiii3869+mgii2798+sliii1892)
suml = suml+(siii187m+siii9532+siv105m)
suml = suml*hb   ;
tin  = tin*1.0e-4;
th   = th *1.0e-4;
printf(" Ltot    E34  ,  133., %7.2f, %6.1f\n", suml   , 100*(suml  -  133.)/ 133.);
printf(" Tinner  K  E4,  1.48, %7.3f, %6.1f\n", tin    , 100*(tin   -  1.48)/ 1.48);
printf(" Th+     K  E4,  1.05, %7.3f, %6.1f\n", th     , 100*(th    -  1.05)/ 1.05);
printf(" <He+>/<H+>   , 0.920, %7.3f, %6.1f\n\n", he2/h2 , 100*((he2/h2)- 0.920)/ 0.920);
}
