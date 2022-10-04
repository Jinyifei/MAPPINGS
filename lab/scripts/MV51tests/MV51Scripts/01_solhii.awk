#
# v5.2.0
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
  cii2326  = 0.0;
  ciii1909 = 0.0;
  nii6584  = 0.0;
  niii57m  = 0.0;
  oi6300   = 0.0;
  oii3727  = 0.0;
  oiii5007 = 0.0;
  oiii518m = 0.0;
  neiii3869 = 0.0;
  neiii155m = 0.0;
  mgii2798  = 0.0;
  slii2335  = 0.0;
  slii348m  = 0.0;
  sii6720   = 0.0;
  siii9532 = 0.0;
  siii187m = 0.0;
  siv105m  = 0.0;
}
/#    <Te>/{line = NR+1}
(NR==line){tin = $2; line = 0}
/Model ended/{liner = NR+1}
(NR==liner){rout = $3}
/ Mass  X,/ {lineion = NR}
(/^ II  /&&(lineion>0)){h2 = $2; he2 = $3; lineion = 0}
/ Average ionic temperatures/ {lineth = NR}
(/^ II   /&&(lineth>0)) {th = $2; lineth = 0}
/H-beta  :,/ { n = split($0, a, ","); hbeta = a[4]}
/1906.683/ {n = split($0, a, ","); ciii1909  = a[3]}
/1908.734/ {n = split($0, a, ","); ciii1909  = ciii1909 + a[3]}
/2323.560/ {n = split($0, a, ","); cii2326   = a[3]}
/2324.695/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2325.408/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2326.989/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2328.127/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2328.517/ {n = split($0, a, ","); slii2335   = a[3]}
/2334.407/ {n = split($0, a, ","); slii2335   = slii2335+a[3]}
/2334.605/ {n = split($0, a, ","); slii2335   = slii2335+a[3]}
/2344.202/ {n = split($0, a, ","); slii2335   = slii2335+a[3]}
/2350.172/ {n = split($0, a, ","); slii2335   = slii2335+a[3]}
/2790.777/ {n = split($0, a, ","); mgii2798  = a[3]}
/2795.528/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/2797.930/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/2797.998/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/2802.705/ {n = split($0, a, ","); mgii2798  = mgii2798+a[3]}
/3726.032/ {n = split($0, a, ","); oii3727   = a[3]}
/3728.815/ {n = split($0, a, ","); oii3727   = oii3727 + a[3]}
/3868.764/ {n = split($0, a, ","); neiii3869 = a[3]}
/3967.471/ {n = split($0, a, ","); neiii3869 = neiii3869 + a[3]}
/4958.911/ {n = split($0, a, ","); oiii5007  = a[3]}
/5006.843/ {n = split($0, a, ","); oiii5007  = oiii5007+a[3]}
/5875.664/ {n = split($0, a, ","); hei5876   = a[3]}
/6300.304/ {n = split($0, a, ","); oi6300    = a[3]}
/6363.776/ {n = split($0, a, ","); oi6300    = oi6300+a[3]}
/6548.052/ {n = split($0, a, ","); nii6584   = a[3]}
/6583.454/ {n = split($0, a, ","); nii6584   = nii6584 + a[3]}
/6716.440/ {n = split($0, a, ","); sii6720   = a[3]}
/6730.816/ {n = split($0, a, ","); sii6720   = sii6720 + a[3]}
/9068.620/ {n = split($0, a, ","); siii9532  = a[3]}
/9530.619/ {n = split($0, a, ","); siii9532  = siii9532 + a[3]}
/105104.947/ {n = split($0, a, ","); siv105m   = a[3]}
/155550.993/ {n = split($0, a, ","); neiii155m = a[3]}
/187129.250/ {n = split($0, a, ","); siii187m  = a[3]}
/348140.927/ {n = split($0, a, ","); slii348m  = a[3]}
/518145.454/ {n = split($0, a, ","); oiii518m  = a[3]}
/573394.495/ {n = split($0, a, ","); niii57m   = a[3]}
/Detailed Emission Spectrum/{
print " MV 5.1 P6 Test 01 Solar metallicty 45kK HII region"
hb = hbeta*1.0e-36
print  " Quantity     ,  P6MV,   Model,  Diff%";
printf(" HBeta   E36  ,  2.293, %7.3f, %6.1f\n", hb        , 100*(hb       - 2.2927)/2.2927);
printf(" HeI     5876 ,  0.125, %7.3f, %6.1f\n", hei5876   , 100*(hei5876  - 0.1248)/0.1248);
printf(" CII]    2326+,  0.023, %7.3f, %6.1f\n", cii2326   , 100*(cii2326  - 0.0230)/0.0230);
printf(" CIII]   1909+,  0.021, %7.3f, %6.1f\n", ciii1909  , 100*(ciii1909 - 0.0210)/0.0210);
printf(" [NII]   6584+,  0.835, %7.3f, %6.1f\n", nii6584   , 100*(nii6584  - 0.8353)/0.8353);
printf(" [NIII]  57m  ,  0.257, %7.3f, %6.1f\n", niii57m   , 100*(niii57m  - 0.2565)/0.2565);
printf(" [OI]    6300+,  0.024, %7.3f, %6.1f\n", oi6300    , 100*(oi6300   - 0.0236)/0.0236);
printf(" [OII]   3727+,  1.540, %7.3f, %6.1f\n", oii3727   , 100*(oii3727  - 1.5395)/1.5395);
printf(" [OIII]  5007+,  0.418, %7.3f, %6.1f\n", oiii5007  , 100*(oiii5007 - 0.4184)/0.4184);
printf(" [OIII]  51.8m,  0.232, %7.3f, %6.1f\n", oiii518m  , 100*(oiii518m - 0.2316)/0.2316);
printf(" [NeIII] 15.5m,  0.243, %7.3f, %6.1f\n", neiii155m , 100*(neiii155m- 0.2428)/0.2428);
printf(" [NeIII] 3869+,  0.038, %7.3f, %6.1f\n", neiii3869 , 100*(neiii3869- 0.0384)/0.0384);
printf(" [MgII]  2798+,  0.266, %7.3f, %6.1f\n", mgii2798  , 100*(mgii2798 - 0.2663)/0.2663);
printf(" [SiII]  34.8m,  2.830, %7.3f, %6.1f\n", slii348m  , 100*(slii348m - 2.8297)/2.8297);
printf(" SiII]   2335+,  0.013, %7.3f, %6.1f\n", slii2335  , 100*(slii2335 - 0.0128)/0.0128);
printf(" [SII]   6720+,  0.304, %7.3f, %6.1f\n", sii6720   , 100*(sii6720  - 0.3040)/0.3040);
printf(" [SIII]  18.7m,  0.605, %7.3f, %6.1f\n", siii187m  , 100*(siii187m - 0.6052)/0.6052);
printf(" [SIII]  9532+,  0.873, %7.3f, %6.1f\n", siii9532  , 100*(siii9532 - 0.8728)/0.8728);
printf(" [SIV]   10.5m,  0.011, %7.3f, %6.1f\n", siv105m   , 100*(siv105m  - 0.0114)/0.0114);
suml =(hei5876+cii2326+ciii1909+nii6584)
suml = suml+(niii57m+oi6300+oii3727+oiii5007)
suml = suml+(oiii518m+neiii3869+neiii155m)
suml = suml+(mgii2798+slii2335+slii348m)
suml = suml+(sii6720+siii9532+siii187m+siv105m)
suml = suml*hb   ;
tin  = tin*1.0e-4;
th   = th *1.0e-4;
r    = rout*1e-20;
printf(" Ltot    E36  , 19.848, %7.3f, %6.1f\n", suml   , 100*(suml     -19.8482)/19.8482);
printf(" Tinner  K  E4,  0.757, %7.3f, %6.1f\n", tin    , 100*(tin      - 0.7566)/ 0.7566);
printf(" Th+     K  E4,  0.664, %7.3f, %6.1f\n", th     , 100*(th       - 0.6644)/ 0.6644);
printf(" <He+>/<H+>   ,  0.985, %7.3f, %6.1f\n", he2/h2 , 100*((he2/h2) - 0.9849)/ 0.9849);
printf(" Rout    E20  ,  1.809, %7.3f, %6.1f\n", r      , 100*(r        - 1.8090)/ 1.8090);
}
