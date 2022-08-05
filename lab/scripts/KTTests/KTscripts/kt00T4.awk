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
  hei5876  = 0.0;
  cii1335  = 0.0;
  cii2326  = 0.0;
  ciii1909 = 0.0;
  nii6584  = 0.0;
  niii57m  = 0.0;
  oii3727  = 0.0;
  oii7330  = 0.0;
  oiii518m = 0.0;
  oiii5007 = 0.0;
  neii128m = 0.0;
  neiii155m = 0.0;
  neiii3869 = 0.0;
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
/1334.532/ {n = split($0, a, ","); cii1335 = a[3]}
/1335.662/ {n = split($0, a, ","); cii1335 = cii1335 +a[3]}
/1335.707/ {n = split($0, a, ","); cii1335 = cii1335 +a[3]}
/1906.683/ {n = split($0, a, ","); ciii1909 = a[3]}
/1908.734/ {n = split($0, a, ","); ciii1909 = ciii1909 + a[3]}
/2323.560/ {n = split($0, a, ","); cii2326   = a[3]}
/2324.695/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2325.408/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2326.989/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/2328.127/ {n = split($0, a, ","); cii2326   = cii2326 + a[3]}
/3726.032/ {n = split($0, a, ","); oii3727 = a[3]}
/3728.815/ {n = split($0, a, ","); oii3727 = oii3727 + a[3]}
/3868.764/ {n = split($0, a, ","); neiii3869 = a[3]}
/3967.471/ {n = split($0, a, ","); neiii3869 = neiii3869 + a[3]}
/4958.911/ {n = split($0, a, ","); oiii5007 = a[3]}
/5006.843/ {n = split($0, a, ","); oiii5007 = oiii5007+a[3]}
/5875.664/ {n = split($0, a, ","); hei5876 = a[3]}
/6548.052/ {n = split($0, a, ","); nii6584 = a[3]}
/6583.454/ {n = split($0, a, ","); nii6584 = nii6584 + a[3]}
/7318.923/ {n = split($0, a, ","); oii7330 = a[3]}
/7319.989/ {n = split($0, a, ","); oii7330 = oii7330 + a[3]}
/7329.665/ {n = split($0, a, ","); oii7330 = oii7330 + a[3]}
/7330.735/ {n = split($0, a, ","); oii7330 = oii7330 + a[3]}
/9068.620/ {n = split($0, a, ","); siii9532 = a[3]}
/9530.619/ {n = split($0, a, ","); siii9532 = siii9532 + a[3]}
/105104.947/ {n = split($0, a, ","); siv105m = a[3]}
/128135.475/ {n = split($0, a, ","); neii128m = a[3]}
/155550.993/ {n = split($0, a, ","); neiii155m = a[3]}
/187129.250/ {n = split($0, a, ","); siii187m = a[3]}
/518145.454/ {n = split($0, a, ","); oiii518m = a[3]}
/573394.495/ {n = split($0, a, ","); niii57m = a[3]}
/Detailed Emission Spectrum/{
print  " Table 4 Kentucky Benchmark Nebulae"
print  " PP 40kK HII blister region"
print  " Quantity     ,  Mean,   Model,  Diff%";
printf(" HBeta   E0   ,  4.62, %7.3f, %6.1f\n", hbeta    , 100*(hbeta     -4.62)/4.62);
printf(" HeI     5876 ,  0.12, %7.3f, %6.1f\n", hei5876  , 100*(hei5876   -0.12)/0.12);
printf(" CII     2326+,  0.18, %7.3f, %6.1f\n", cii2326  , 100*(cii2326   -0.18)/0.18);
printf(" CII     1335+,  0.09, %7.3f, %6.1f\n", cii1335  , 100*(cii1335   -0.09)/0.09);
printf(" CIII]   1909+,  0.17, %7.3f, %6.1f\n", ciii1909 , 100*(ciii1909  -0.17)/0.17);
printf(" [NII]   6584+,  0.87, %7.3f, %6.1f\n", nii6584  , 100*(nii6584   -0.87)/0.87);
printf(" [NIII]  57m  ,  0.03, %7.3f, %6.1f\n", niii57m  , 100*(niii57m   -0.03)/0.03);
printf(" [OII]   7330+,  0.12, %7.3f, %6.1f\n", oii7330  , 100*(oii7330   -0.12)/0.12);
printf(" [OII]   3727+,  0.88, %7.3f, %6.1f\n", oii3727  , 100*(oii3727   -0.88)/0.88);
printf(" [OIII]  51.8m,  0.29, %7.3f, %6.1f\n", oiii518m , 100*(oiii518m  -0.29)/0.29);
printf(" [OIII]  5007+,  4.13, %7.3f, %6.1f\n", oiii5007 , 100*(oiii5007  -4.13)/4.13);
printf(" [NeII]  12.8m,  0.36, %7.3f, %6.1f\n", neii128m , 100*(neii128m  -0.36)/0.36);
printf(" [NeIII] 15.5m,  0.98, %7.3f, %6.1f\n", neiii155m, 100*(neiii155m -0.98)/0.98);
printf(" [NeIII] 3869+,  0.33, %7.3f, %6.1f\n", neiii3869, 100*(neiii3869 -0.33)/0.33);
printf(" [SIII]  18.7m,  0.35, %7.3f, %6.1f\n", siii187m , 100*(siii187m  -0.35)/0.35);
printf(" [SIII]  9532+,  1.53, %7.3f, %6.1f\n", siii9532 , 100*(siii9532  -1.53)/1.53);
printf(" [SIV]   10.5m,  0.46, %7.3f, %6.1f\n", siv105m  , 100*(siv105m   -0.46)/0.46);
suml =      (hei5876+cii2326+cii1335+ciii1909+nii6584)
suml = suml+(niii57m+oii7330+oii3727+oiii518m+oiii5007)
suml = suml+(neii128m+neiii155m+neiii3869+siii187m)
suml = suml+(siii9532+siv105m)
suml = suml*hbeta
r    = rout*1e-17
printf(" Ltot    E0   , 50.30, %7.3f, %6.1f\n", suml   , 100*(suml     -50.30)/50.30);
printf(" Tinner  K    , 7989., %7.0f, %6.1f\n", tin    , 100*(tin      -7989.)/7989.);
printf(" Th+     K    , 8263., %7.0f, %6.1f\n", th     , 100*(th       -8263.)/8263.);
printf(" <He+>/<H+>   , 0.850, %7.3f, %6.1f\n", he2/h2 , 100*((he2/h2) -0.850)/0.850);
printf(" Rout    E17  ,  2.96, %7.3f, %6.1f\n\n", r      , 100*(r        -2.96)/2.96);
}
