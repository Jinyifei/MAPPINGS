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
  lyalph   = 0.0;
  hei5876  = 0.0;
  heii4686 = 0.0;
  heii1640 = 0.0;
  cii1335  = 0.0;
  cii2326  = 0.0;
  ciii1909 = 0.0;
  civ1549  = 0.0;
  nii6584  = 0.0;
  niii1749 = 0.0;
  niv1487  = 0.0;
  oi6300   = 0.0;
  oi63m    = 0.0;
  oii3727  = 0.0;
  oiii1663 = 0.0;
  oiii5007 = 0.0;
  oiii4363 = 0.0;
  oiv1403  = 0.0;
  neiii3869 = 0.0;
  neiii155m = 0.0;
  neiv2423  = 0.0;
  nev3426   = 0.0;
  mgii2798  = 0.0;
  slii348m  = 0.0;
  sii6720   = 0.0;
  siii9532 = 0.0;
  siii187m = 0.0;
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
/1215.670/ {n = split($0, a, ","); lyalph   = a[3]}
/1334.532/ {n = split($0, a, ","); cii1335 = a[3]}
/1335.663/ {n = split($0, a, ","); cii1335 = cii1335 +a[3]}
/1335.708/ {n = split($0, a, ","); cii1335 = cii1335 +a[3]}
/1397.226/ {n = split($0, a, ","); oiv1403   = a[3]}
/1399.776/ {n = split($0, a, ","); oiv1403   = oiv1403+a[3]}
/1401.163/ {n = split($0, a, ","); oiv1403   = oiv1403+a[3]}
/1404.806/ {n = split($0, a, ","); oiv1403   = oiv1403+a[3]}
/1407.384/ {n = split($0, a, ","); oiv1403   = oiv1403+a[3]}
/1483.321/ {n = split($0, a, ","); niv1487   = a[3]}
/1486.496/ {n = split($0, a, ","); niv1487   = niv1487+a[3]}
/1548.187/ {n = split($0, a, ","); civ1549   = a[3]}
/1550.772/ {n = split($0, a, ","); civ1549   = civ1549 + a[3]}
/1640.417/ {n = split($0, a, ","); heii1640    = a[3]}
/1660.809/ {n = split($0, a, ","); oiii1663   = a[3]}
/1666.150/ {n = split($0, a, ","); oiii1663   = oiii1663 + a[3]}
/1746.823/ {n = split($0, a, ","); niii1749   = a[3]}
/1748.646/ {n = split($0, a, ","); niii1749   = niii1749+a[3]}
/1749.674/ {n = split($0, a, ","); niii1749   = niii1749+a[3]}
/1752.160/ {n = split($0, a, ","); niii1749   = niii1749+a[3]}
/1753.995/ {n = split($0, a, ","); niii1749   = niii1749+a[3]}
/1906.683/ {n = split($0, a, ","); ciii1909  = a[3]}
/1908.734/ {n = split($0, a, ","); ciii1909  = ciii1909 + a[3]}
/2323.560/ {n = split($0, a, ","); cii2326   = a[3]}
/2324.695/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2325.408/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2326.989/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2328.127/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2421.810/ {n = split($0, a, ","); neiv2423  = a[3]}
/2424.422/ {n = split($0, a, ","); neiv2423  = neiv2423 + a[3]}
/2790.777/ {n = split($0, a, ","); mgii2798  = a[3]}
/2795.528/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/2797.930/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/2797.998/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/2802.705/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/3345.821/ {n = split($0, a, ","); nev3426  = a[3]}
/3425.881/ {n = split($0, a, ","); nev3426  = nev3426 + a[3]}
/3726.032/ {n = split($0, a, ","); oii3727 = a[3]}
/3728.815/ {n = split($0, a, ","); oii3727 = oii3727 + a[3]}
/3868.764/ {n = split($0, a, ","); neiii3869 = a[3]}
/3967.471/ {n = split($0, a, ","); neiii3869 = neiii3869 + a[3]}
/4363.209/ {n = split($0, a, ","); oiii4363  = a[3]}
/4685.702/ {n = split($0, a, ","); heii4686  = a[3]}
/4958.911/ {n = split($0, a, ","); oiii5007  = a[3]}
/5006.843/ {n = split($0, a, ","); oiii5007  = oiii5007+a[3]}
/5875.664/ {n = split($0, a, ","); hei5876   = a[3]}
/6300.304/ {n = split($0, a, ","); oi6300    = a[3]}
/6363.776/ {n = split($0, a, ","); oi6300    = oi6300+a[3]}
/6548.052/ {n = split($0, a, ","); nii6584 = a[3]}
/6583.454/ {n = split($0, a, ","); nii6584 = nii6584 + a[3]}
/6716.440/ {n = split($0, a, ","); sii6720   = a[3]}
/6730.816/ {n = split($0, a, ","); sii6720   = sii6720 + a[3]}
/9068.620/ {n = split($0, a, ","); siii9532  = a[3]}
/9530.619/ {n = split($0, a, ","); siii9532  = siii9532 + a[3]}
/105104.947/ {n = split($0, a, ","); siv105m   = a[3]}
/155550.993/ {n = split($0, a, ","); neiii155m = a[3]}
/187129.250/ {n = split($0, a, ","); siii187m  = a[3]}
/348140.927/ {n = split($0, a, ","); slii348m  = a[3]}
/631000.000/ {n = split($0, a, ","); oi63m     = a[3]}
/631851.641/ {n = split($0, a, ","); oi63m     = oi63m + a[3]}
/Detailed Emission Spectrum/{
print " Table 8 Kentucky Benchmark Nebulae"
print " AGN NLR powerlaw"
hb = hbeta*1.0
print  " Quantity     ,  Mean,   Model,  Diff%";
printf(" HBeta   E0   ,  1.31, %7.3f, %6.1f\n", hb       , 100*(hb       - 1.31)/ 1.31);
printf(" LyAlpha 1216 , 34.20, %7.3f, %6.1f\n", lyalph   , 100*(lyalph   -34.20)/34.20);
printf(" HeI     5876 ,  0.12, %7.3f, %6.1f\n", hei5876  , 100*(hei5876  - 0.12)/ 0.12);
printf(" HeII    4686 ,  0.24, %7.3f, %6.1f\n", heii4686 , 100*(heii4686 - 0.24)/ 0.24);
printf(" HeII    1640 ,  1.60, %7.3f, %6.1f\n", heii1640 , 100*(heii1640 - 1.60)/ 1.60);
printf(" CIII]   1909+,  2.82, %7.3f, %6.1f\n", ciii1909 , 100*(ciii1909 - 2.82)/ 2.82);
printf(" CIV     1549+,  3.18, %7.3f, %6.1f\n", civ1549  , 100*(civ1549  - 3.18)/ 3.18);
printf(" [NII]   6584+,  2.33, %7.3f, %6.1f\n", nii6584  , 100*(nii6584  - 2.33)/ 2.33);
printf(" [NIII]  1749+,  0.19, %7.3f, %6.1f\n", niii1749 , 100*(niii1749 - 0.19)/ 0.19);
printf(" NIV]    1487+,  0.20, %7.3f, %6.1f\n", niv1487  , 100*(niv1487  - 0.20)/ 0.20);
printf(" [OI]    6300+,  1.61, %7.3f, %6.1f\n", oi6300   , 100*(oi6300   - 1.61)/ 1.61);
printf(" [OI]    63m  ,  1.12, %7.3f, %6.1f\n", oi63m    , 100*(oi63m    - 1.12)/ 1.12);
printf(" [OII]   3727+,  1.72, %7.3f, %6.1f\n", oii3727  , 100*(oii3727  - 1.72)/ 1.72);
printf(" [OIII]  1663+,  0.56, %7.3f, %6.1f\n", oiii1663 , 100*(oiii1663 - 0.56)/ 0.56);
printf(" [OIII]  5007+, 33.10, %7.3f, %6.1f\n", oiii5007 , 100*(oiii5007 -33.10)/33.10);
printf(" [OIII]  4363 ,  0.32, %7.3f, %6.1f\n", oiii4363 , 100*(oiii4363 - 0.32)/ 0.32);
printf(" OIV]    1403+,  0.36, %7.3f, %6.1f\n", oiv1403  , 100*(oiv1403  - 0.36)/ 0.36);
printf(" [NeIII] 15.5m,  1.89, %7.3f, %6.1f\n", neiii155m, 100*(neiii155m- 1.89)/ 1.89);
printf(" [NeIII] 3869+,  1.91, %7.3f, %6.1f\n", neiii3869, 100*(neiii3869- 1.91)/ 1.91);
printf(" NeIV]   2423+,  0.44, %7.3f, %6.1f\n", neiv2423 , 100*(neiv2423 - 0.44)/ 0.44);
printf(" [NeV]   3426+,  0.52, %7.3f, %6.1f\n", nev3426  , 100*(nev3426  - 0.52)/ 0.52);
printf(" [MgII]  2798+,  1.78, %7.3f, %6.1f\n", mgii2798 , 100*(mgii2798 - 1.78)/ 1.78);
printf(" [SiII]  34.8m,  0.90, %7.3f, %6.1f\n", slii348m , 100*(slii348m - 0.90)/ 0.90);
printf(" [SII]   6720+,  1.33, %7.3f, %6.1f\n", sii6720  , 100*(sii6720  - 1.33)/ 1.33);
printf(" [SIII]  9532+,  1.88, %7.3f, %6.1f\n", siii9532 , 100*(siii9532 - 1.88)/ 1.88);
printf(" [SIII]  18.7m,  0.49, %7.3f, %6.1f\n", siii187m , 100*(siii187m - 0.49)/ 0.49);
printf(" [SIV]   10.5m,  1.05, %7.3f, %6.1f\n", siv105m  , 100*(siv105m  - 1.05)/ 1.05);
suml =       (lyalph+hei5876+heii4686+heii1640+ciii1909)
suml = suml+(civ1549+nii6584+niii1749+niv1487+oi6300)
suml = suml+(oi63m+oii3727+oiii1663+oiii5007+oiii4363)
suml = suml+(oiv1403+neiii3869+neiii155m+neiv2423+nev3426)
suml = suml+(mgii2798+slii348m+sii6720+siii9532+siii187m+siv105m)
suml = suml*hb   ;
tin  = tin*1.0e-4;
th   = th *1.0e-4;
printf(" Ltot    E0   ,  125., %7.2f, %6.1f\n", suml  , 100*(suml- 125.)/125.);
printf(" Tinner  K  E4,  1.70, %7.3f, %6.1f\n", tin   , 100*(tin - 1.70)/1.70);
printf(" Th+     K  E4,  1.17, %7.3f, %6.1f\n\n", th    , 100*(th  - 1.17)/1.17);
}
