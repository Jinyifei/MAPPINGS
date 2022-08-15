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
  hei5876  = 0.0;
  cii2326  = 0.0;
  ciii1909 = 0.0;
  nii122   = 0.0;
  nii6584  = 0.0;
  niii57m  = 0.0;
  oii3727  = 0.0;
  oiii518m = 0.0;
  oiii88m  = 0.0;
  oiii5007 = 0.0;
  neii128m = 0.0;
  neiii155m = 0.0;
  neiii3869 = 0.0;
  sii6720  = 0.0;
  siii187m = 0.0;
  siii34m  = 0.0;
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
/6716.440/ {n = split($0, a, ","); sii6720 = a[3]}
/6730.816/ {n = split($0, a, ","); sii6720 = sii6720 + a[3]}
/9068.620/ {n = split($0, a, ","); siii9532 = a[3]}
/9530.619/ {n = split($0, a, ","); siii9532 = siii9532 + a[3]}
/105104.947/ {n = split($0, a, ","); siv105m = a[3]}
/128135.475/ {n = split($0, a, ","); neii128m = a[3]}
/155550.993/ {n = split($0, a, ","); neiii155m = a[3]}
/187129.250/ {n = split($0, a, ","); siii187m = a[3]}
/334795.273/ {n = split($0, a, ","); siii34m = a[3]}
/518145.454/ {n = split($0, a, ","); oiii518m = a[3]}
/573394.495/ {n = split($0, a, ","); niii57m = a[3]}
/883563.944/ {n = split($0, a, ","); oiii88m = a[3]}
/1218026.797/ { n = split($0, a, ","); nii122 = a[3]}
/Detailed Emission Spectrum/{
print  " Table 3 Kentucky Benchmark Nebulae";
print  " 40kK HII region";
print  " Quantity     ,  Mean,   Model,  Diff%";
hb = (hbeta*1e-37)
printf(" HBeta   E37  ,  2.03, %7.3f, %6.1f\n", hb       , 100*(hb       -2.03)/2.03);
printf(" HeI     5876 ,  0.12, %7.3f, %6.1f\n", hei5876  , 100*(hei5876  -0.12)/0.12);
printf(" CII     2326+,  0.16, %7.3f, %6.1f\n", cii2326  , 100*(cii2326  -0.16)/0.16);
printf(" CIII]   1909+,  0.06, %7.3f, %6.1f\n", ciii1909 , 100*(ciii1909 -0.06)/0.06);
printf(" [NII]   122m ,  0.03, %7.3f, %6.1f\n", nii122   , 100*(nii122   -0.03)/0.03);
printf(" [NII]   6584+,  0.79, %7.3f, %6.1f\n", nii6584  , 100*(nii6584  -0.79)/0.79);
printf(" [NIII]  57m  ,  0.27, %7.3f, %6.1f\n", niii57m  , 100*(niii57m  -0.27)/0.27);
printf(" [OII]   3727+,  2.16, %7.3f, %6.1f\n", oii3727  , 100*(oii3727  -2.16)/2.16);
printf(" [OIII]  51.8m,  1.07, %7.3f, %6.1f\n", oiii518m , 100*(oiii518m -1.07)/1.07);
printf(" [OIII]  88.4m,  1.23, %7.3f, %6.1f\n", oiii88m  , 100*(oiii88m  -1.23)/1.23);
printf(" [OIII]  5007+,  2.06, %7.3f, %6.1f\n", oiii5007 , 100*(oiii5007 -2.06)/2.06);
printf(" [NeII]  12.8m,  0.22, %7.3f, %6.1f\n", neii128m , 100*(neii128m -0.22)/0.22);
printf(" [NeIII] 15.5m,  0.38, %7.3f, %6.1f\n", neiii155m, 100*(neiii155m-0.38)/0.38);
printf(" [NeIII] 3869+,  0.09, %7.3f, %6.1f\n", neiii3869, 100*(neiii3869-0.09)/0.09);
printf(" [SII]   6720+,  0.20, %7.3f, %6.1f\n", sii6720  , 100*(sii6720  -0.20)/0.20);
printf(" [SIII]  18.7m,  0.55, %7.3f, %6.1f\n", siii187m , 100*(siii187m -0.55)/0.55);
printf(" [SIII]  34m  ,  0.89, %7.3f, %6.1f\n", siii34m  , 100*(siii34m  -0.89)/0.89);
printf(" [SIII]  9532+,  1.29, %7.3f, %6.1f\n", siii9532 , 100*(siii9532 -1.29)/1.29);
printf(" [SIV]   10.5m,  0.34, %7.3f, %6.1f\n", siv105m  , 100*(siv105m  -0.34)/0.34);
suml =      (hei5876+cii2326+ciii1909+nii122+nii6584)
suml = suml+(niii57m+oii3727+oiii518m+oiii88m+oiii5007)
suml = suml+(neii128m+neiii155m+neiii3869+sii6720+siii187m)
suml = suml+(siii34m+siii9532+siv105m)
suml = suml*(hbeta*1e-37)
r    = rout*1e-19
printf(" Ltot    E37  , 24.20, %7.3f, %6.1f\n", suml  , 100*(suml-24.20)/24.20);
printf(" Tinner  K    , 7552., %7.0f, %6.1f\n", tin   , 100*(tin  -7552.)/7552.);
printf(" Th+     K    , 8034., %7.0f, %6.1f\n", th    , 100*(th   -8034.)/8034.);
printf(" <He+>/<H+>   , 0.770, %7.3f, %6.1f\n", he2/h2, 100*((he2/h2)-0.770)/0.770);
printf(" Rout    E19  ,  1.48, %7.3f, %6.1f\n\n", r     , 100*(r-1.48)/1.48);
}
