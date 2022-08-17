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
  cii2326  = 0.0;
  ciii1909 = 0.0;
  civ1549  = 0.0;
  nii6584  = 0.0;
  niii1749  = 0.0;
  niii57m  = 0.0;
  niv1487  = 0.0;
  nv1240   = 0.0;
  oi6300   = 0.0;
  oii3727  = 0.0;
  oiii4363 = 0.0;
  oiii5007 = 0.0;
  oiii518m = 0.0;
  oiv1403  = 0.0;
  oiv26m   = 0.0;
  ov1218   = 0.0;
  neiii3869 = 0.0;
  neiii155m = 0.0;
  neiv2423  = 0.0;
  nev3426   = 0.0;
  nev242m   = 0.0;
  mgii2798  = 0.0;
  mgiv45m   = 0.0;
  slii2335  = 0.0;
  slii348m  = 0.0;
  sliii1892 = 0.0;
  sliv1397  = 0.0;
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
/1213.809/ {n = split($0, a, ","); ov1218   = a[3]}
/1218.344/ {n = split($0, a, ","); ov1218   = ov1218+a[3]}
/1238.821/ {n = split($0, a, ","); nv1240   = a[3]}
/1242.804/ {n = split($0, a, ","); nv1240   = nv1240+a[3]}
/1393.755/ {n = split($0, a, ","); sliv1397   = a[3]}
/1402.770/ {n = split($0, a, ","); sliv1397   = sliv1397+a[3]}
/1397.226/ {n = split($0, a, ","); oiv1403   = a[3]}
/1399.776/ {n = split($0, a, ","); oiv1403   = oiv1403+a[3]}
/1401.163/ {n = split($0, a, ","); oiv1403   = oiv1403+a[3]}
/1404.806/ {n = split($0, a, ","); oiv1403   = oiv1403+a[3]}
/1407.384/ {n = split($0, a, ","); oiv1403   = oiv1403+a[3]}
/1483.321/ {n = split($0, a, ","); niv1487   = a[3]}
/1486.496/ {n = split($0, a, ","); niv1487   = niv1487+a[3]}
/1548.187/ {n = split($0, a, ","); civ1549   = a[3]}
/1550.772/ {n = split($0, a, ","); civ1549   = civ1549 + a[3]}
/1746.823/ {n = split($0, a, ","); niii1749  = a[3]}
/1748.646/ {n = split($0, a, ","); niii1749  = niii1749+a[3]}
/1749.674/ {n = split($0, a, ","); niii1749  = niii1749+a[3]}
/1752.160/ {n = split($0, a, ","); niii1749  = niii1749+a[3]}
/1753.995/ {n = split($0, a, ","); niii1749  = niii1749+a[3]}
/1882.707/ {n = split($0, a, ","); sliii1892 = a[3]}
/1892.029/ {n = split($0, a, ","); sliii1892 = sliii1892 + a[3]}
/1906.683/ {n = split($0, a, ","); ciii1909  = a[3]}
/1908.734/ {n = split($0, a, ","); ciii1909  = ciii1909 + a[3]}
/2323.560/ {n = split($0, a, ","); cii2326   = a[3]}
/2324.695/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2325.408/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2326.989/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2328.127/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2328.517/ {n = split($0, a, ","); slii2335 = a[3]}
/2334.407/ {n = split($0, a, ","); slii2335 = slii2335+a[3]}
/2334.605/ {n = split($0, a, ","); slii2335 = slii2335+a[3]}
/2344.202/ {n = split($0, a, ","); slii2335 = slii2335+a[3]}
/2350.172/ {n = split($0, a, ","); slii2335 = slii2335+a[3]}
/2421.810/ {n = split($0, a, ","); neiv2423 = a[3]}
/2424.422/ {n = split($0, a, ","); neiv2423 = neiv2423 + a[3]}
/2790.777/ {n = split($0, a, ","); mgii2798 = a[3]}
/2795.528/ {n = split($0, a, ","); mgii2798 = mgii2798+a[3]}
/2797.930/ {n = split($0, a, ","); mgii2798 = mgii2798+a[3]}
/2797.998/ {n = split($0, a, ","); mgii2798 = mgii2798+a[3]}
/2802.705/ {n = split($0, a, ","); mgii2798 = mgii2798+a[3]}
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
/44883.303/ {n = split($0, a, ","); mgiv45m   =  a[3]}
/105104.947/ {n = split($0, a, ","); siv105m   = a[3]}
/155550.993/ {n = split($0, a, ","); neiii155m = a[3]}
/187129.250/ {n = split($0, a, ","); siii187m  = a[3]}
/243174.694/ {n = split($0, a, ","); nev242m    = a[3]}
/258933.195/ {n = split($0, a, ","); oiv26m    = a[3]}
/348140.927/ {n = split($0, a, ","); slii348m  = a[3]}
/518145.454/ {n = split($0, a, ","); oiii518m  = a[3]}
/573394.495/ {n = split($0, a, ","); niii57m   = a[3]}
/Detailed Emission Spectrum/{
print " Table 5 Kentucky Benchmark Nebulae"
print " Meudon 150kK PN"
hb = hbeta*1.0e-35
print  " Quantity     ,  Mean,   Model,  Diff%";
printf(" HBeta   E35  ,  2.53, %7.3f, %6.1f\n", hb        , 100*(hb       - 2.53)/ 2.53);
printf(" HeI     5876 ,  0.09, %7.3f, %6.1f\n", hei5876   , 100*(hei5876  - 0.09)/ 0.09);
printf(" HeII    4686 ,  0.41, %7.3f, %6.1f\n", heii4686  , 100*(heii4686 - 0.41)/ 0.41);
printf(" CII]    2326+,  0.27, %7.3f, %6.1f\n", cii2326   , 100*(cii2326  - 0.27)/ 0.27);
printf(" CIII]   1909+,  2.14, %7.3f, %6.1f\n", ciii1909  , 100*(ciii1909 - 2.14)/ 2.14);
printf(" CIV     1549+,  2.51, %7.3f, %6.1f\n", civ1549   , 100*(civ1549  - 2.51)/ 2.51);
printf(" [NII]   6584+,  1.49, %7.3f, %6.1f\n", nii6584   , 100*(nii6584  - 1.49)/ 1.49);
printf(" [NIII]  1749+,  0.12, %7.3f, %6.1f\n", niii1749  , 100*(niii1749 - 0.12)/ 0.12);
printf(" [NIII]  57m  ,  0.13, %7.3f, %6.1f\n", niii57m   , 100*(niii57m  - 0.13)/ 0.13);
printf(" NIV]    1487+,  0.20, %7.3f, %6.1f\n", niv1487   , 100*(niv1487  - 0.20)/ 0.20);
printf(" NV      1240+,  0.21, %7.3f, %6.1f\n", nv1240    , 100*(nv1240   - 0.21)/ 0.21);
printf(" [OI]    6300+,  0.14, %7.3f, %6.1f\n", oi6300    , 100*(oi6300   - 0.14)/ 0.14);
printf(" [OII]   3727+,  2.28, %7.3f, %6.1f\n", oii3727   , 100*(oii3727  - 2.28)/ 2.28);
printf(" [OIII]  5007+, 20.70, %7.3f, %6.1f\n", oiii5007  , 100*(oiii5007 -20.70)/20.70);
printf(" [OIII]  4363 ,  0.16, %7.3f, %6.1f\n", oiii4363  , 100*(oiii4363 - 0.16)/ 0.16);
printf(" [OIII]  51.8m,  1.34, %7.3f, %6.1f\n", oiii518m  , 100*(oiii518m - 1.34)/ 1.34);
printf(" [OIV]   26m  ,  3.92, %7.3f, %6.1f\n", oiv26m    , 100*(oiv26m   - 3.92)/ 3.92);
printf(" OIV]    1403+,  0.27, %7.3f, %6.1f\n", oiv1403   , 100*(oiv1403  - 0.27)/ 0.27);
printf(" OV]     1218+,  0.24, %7.3f, %6.1f\n", ov1218    , 100*(ov1218   - 0.24)/ 0.24);
printf(" [NeIII] 15.5m,  2.49, %7.3f, %6.1f\n", neiii155m , 100*(neiii155m- 2.49)/ 2.49);
printf(" [NeIII] 3869+,  2.63, %7.3f, %6.1f\n", neiii3869 , 100*(neiii3869- 2.63)/ 2.63);
printf(" NeIV]   2423+,  0.95, %7.3f, %6.1f\n", neiv2423  , 100*(neiv2423 - 0.95)/ 0.95);
printf(" [NeV]   3426+,  0.90, %7.3f, %6.1f\n", nev3426   , 100*(nev3426  - 0.90)/ 0.90);
printf(" [NeV]   24.2m,  0.88, %7.3f, %6.1f\n", nev242m   , 100*(nev242m  - 0.88)/ 0.88);
printf(" [MgII]  2798+,  1.56, %7.3f, %6.1f\n", mgii2798  , 100*(mgii2798 - 1.56)/ 1.56);
printf(" [MgIV]  4.5m ,  0.12, %7.3f, %6.1f\n", mgiv45m   , 100*(mgiv45m  - 0.12)/ 0.12);
printf(" [SiII]  34.8m,  0.18, %7.3f, %6.1f\n", slii348m  , 100*(slii348m - 0.18)/ 0.18);
printf(" SiII]   2335+,  0.23, %7.3f, %6.1f\n", slii2335  , 100*(slii2335 - 0.23)/ 0.23);
printf(" SiIII]  1892+,  0.68, %7.3f, %6.1f\n", sliii1892 , 100*(sliii1892- 0.68)/ 0.68);
printf(" SiIV    1397+,  0.15, %7.3f, %6.1f\n", sliv1397  , 100*(sliv1397 - 0.15)/ 0.15);
printf(" [SII]   6720+,  0.33, %7.3f, %6.1f\n", sii6720   , 100*(sii6720  - 0.33)/ 0.33);
printf(" [SIII]  18.7m,  0.53, %7.3f, %6.1f\n", siii187m  , 100*(siii187m - 0.53)/ 0.53);
printf(" [SIII]  9532+,  1.91, %7.3f, %6.1f\n", siii9532  , 100*(siii9532 - 1.91)/ 1.91);
printf(" [SIV]   10.5m,  1.84, %7.3f, %6.1f\n", siv105m   , 100*(siv105m  - 1.84)/ 1.84);
suml =(hei5876+heii4686+cii2326+ciii1909+civ1549+nii6584+niii1749)
suml = suml+(niii57m+niv1487+nv1240+oi6300+oii3727+oiii4363+oiii5007)
suml = suml+(oiii518m+oiv26m+ov1218+neiii3869+neiii155m+neiv2423+nev3426)
suml = suml+(nev242m+mgii2798+mgiv45m+slii2335+slii348m+sliii1892)
suml = suml+(sliv1397+sii6720+siii9532+siii187m+siv105m+oiv1403)
suml = suml*hb   ;
tin  = tin*1.0e-4;
th   = th *1.0e-4;
r    = rout*1e-17;
printf(" Ltot    E35  ,  132., %7.2f, %6.1f\n", suml   , 100*(suml     - 132.)/ 132.);
printf(" Tinner  K  E4,  1.80, %7.3f, %6.1f\n", tin    , 100*(tin      - 1.80)/ 1.80);
printf(" Th+     K  E4,  1.26, %7.3f, %6.1f\n", th     , 100*(th       - 1.26)/ 1.26);
printf(" <He+>/<H+>   , 0.690, %7.3f, %6.1f\n", he2/h2 , 100*((he2/h2) -0.690)/0.690);
printf(" Rout    E17  ,  4.02, %7.3f, %6.1f\n\n", r      , 100*(r        - 4.02)/ 4.02);
}
