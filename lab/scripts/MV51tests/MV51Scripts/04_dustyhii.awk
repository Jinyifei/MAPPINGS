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
  halpha   = 0.0;
  hei5876  = 0.0;
  ciii1909 = 0.0;
  nii6584  = 0.0;
  niii57m  = 0.0;
  oi6300   = 0.0;
  oii3727  = 0.0;
  oiii4363 = 0.0;
  oiii5007 = 0.0;
  oiii518m = 0.0;
  oiii883m = 0.0;
  neii128m = 0.0;
  neiii155m = 0.0;
  neiii3869 = 0.0;
  sii6731   = 0.0;
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
/3726.032/ {n = split($0, a, ","); oii3727   = a[3]}
/3728.815/ {n = split($0, a, ","); oii3727   = oii3727 + a[3]}
/3868.764/ {n = split($0, a, ","); neiii3869 = a[3]}
/3967.471/ {n = split($0, a, ","); neiii3869 = neiii3869 + a[3]}
/4363.209/ {n = split($0, a, ","); oiii4363  = a[3]}
/4958.911/ {n = split($0, a, ","); oiii5007  = a[3]}
/5006.843/ {n = split($0, a, ","); oiii5007  = oiii5007+a[3]}
/5875.664/ {n = split($0, a, ","); hei5876   = a[3]}
/6300.304/ {n = split($0, a, ","); oi6300    = a[3]}
/6548.052/ {n = split($0, a, ","); nii6584   = a[3]}
/6562.819/ {n = split($0, a, ","); halpha  = a[3]}
/6583.454/ {n = split($0, a, ","); nii6584   = nii6584 + a[3]}
/6716.440/ {n = split($0, a, ","); sii6720   = a[3]}
/6730.816/ {n = split($0, a, ","); sii6720   = sii6720 + a[3]}
/9068.620/ {n = split($0, a, ","); siii9532  = a[3]}
/9530.619/ {n = split($0, a, ","); siii9532  = siii9532 + a[3]}
/105104.947/ {n = split($0, a, ","); siv105m   = a[3]}
/128135.475/ {n = split($0, a, ","); neii128m = a[3]}
/155550.993/ {n = split($0, a, ","); neiii155m = a[3]}
/187129.250/ {n = split($0, a, ","); siii187m  = a[3]}
/518145.454/ {n = split($0, a, ","); oiii518m  = a[3]}
/883563.944/ {n = split($0, a, ","); oiii883m = a[3]}
/Detailed Emission Spectrum/{
print  " MV 5.1.20 P6 Test Dusty Low Z HII Region"
print  " Quantity     ,  MVP6,  Model,  Diff%";
hb = hbeta*1e-37
printf(" HBeta   E37  ,  5.009,%7.3f, %6.1f\n", hb       , 100*(hb        -5.0088)/5.0088);
printf(" HI      6562 ,  2.893,%7.3f, %6.1f\n", halpha   , 100*(halpha    -2.8929)/2.8929);
printf(" HeI     5876 ,  0.092,%7.3f, %6.1f\n", hei5876  , 100*(hei5876   -0.0918)/0.0918);
printf(" CIII]   1909+,  0.222,%7.3f, %6.1f\n", ciii1909 , 100*(ciii1909  -0.2220)/0.2220);
printf(" [NII]   6584+,  0.016,%7.3f, %6.1f\n", nii6584  , 100*(nii6584   -0.0159)/0.0159);
printf(" [OI]    6300 ,  0.019,%7.3f, %6.1f\n", oi6300   , 100*(oi6300    -0.0189)/0.0189);
printf(" [OII]   3727+,  1.014,%7.3f, %6.1f\n", oii3727  , 100*(oii3727   -1.0136)/1.0136);
printf(" [OIII]  4363 ,  0.064,%7.3f, %6.1f\n", oiii4363 , 100*(oiii4363  -0.0641)/0.0641);
printf(" [OIII]  5007+,  3.884,%7.3f, %6.1f\n", oiii5007 , 100*(oiii5007  -3.8843)/3.8843);
printf(" [OIII]  51.8m,  0.263,%7.3f, %6.1f\n", oiii518m , 100*(oiii518m  -0.2633)/0.2633);
printf(" [OIII]  88.3m,  0.444,%7.3f, %6.1f\n", oiii883m , 100*(oiii883m  -0.4440)/0.4440);
printf(" [NeIII] 3869+,  0.377,%7.3f, %6.1f\n", neiii3869, 100*(neiii3869 -0.3769)/0.3769);
printf(" [NeIII] 15.5m,  0.145,%7.3f, %6.1f\n", neiii155m, 100*(neiii155m -0.1451)/0.1451);
printf(" [SII]   6731+,  0.109,%7.3f, %6.1f\n", sii6720  , 100*(sii6720   -0.1085)/0.1085);
printf(" [SIII]  9532+,  0.481,%7.3f, %6.1f\n", siii9532 , 100*(siii9532  -0.4811)/0.4811);
printf(" [SIII]  18.7m,  0.113,%7.3f, %6.1f\n", siii187m , 100*(siii187m  -0.1127)/0.1127);
printf(" [SIV]   10.5m,  0.109,%7.3f, %6.1f\n", siv105m  , 100*(siv105m   -0.1087)/0.1087);
suml =      (halpha+hei5876+ciii1909+nii6584+oi6300)
suml = suml+(oii3727+oiii4363+oiii5007+oiii518m+oiii883m)
suml = suml+(neiii3869+neiii155m+sii6731+siii9532)
suml = suml+(siii187m+siv105m)
suml = suml*hb
tin  = tin*1.0e-4
th   = th *1.0e-4
r    = rout*1e-20
printf(" Ltot    E20  , 50.767,%7.3f, %6.1f\n", suml   , 100*(suml     -50.7665)/50.7665);
printf(" Tinner  K E4 ,  2.417,%7.3f, %6.1f\n", tin    , 100*(tin      - 2.4166)/ 2.4166);
printf(" Th+     K E4 ,  1.511,%7.3f, %6.1f\n", th     , 100*(th       - 1.5110)/ 1.5110);
printf(" <He+>/<H+>   ,  1.012,%7.3f, %6.1f\n", he2/h2 , 100*((he2/h2) - 1.0116)/ 1.0116);
printf(" Rout    E20  ,  2.396,%7.3f, %6.1f\n", r      , 100*(r        - 2.3960)/ 2.3960);
}
