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
  oii3727  = 0.0;
  nii6584  = 0.0;
  sii6720  = 0.0;
  siii187m = 0.0;
  siii34m  = 0.0;
  siii9532 = 0.0;
  neii128m = 0.0;
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
/3726.032/ {n = split($0, a, ","); oii3727 = a[3]}
/3728.815/ {n = split($0, a, ","); oii3727 = oii3727 + a[3]}
/6548.052/ {n = split($0, a, ","); nii6584 = a[3]}
/6583.454/ {n = split($0, a, ","); nii6584 = nii6584 + a[3]}
/6716.440/ {n = split($0, a, ","); sii6720 = a[3]}
/6730.816/ {n = split($0, a, ","); sii6720 = sii6720 + a[3]}
/9068.620/ {n = split($0, a, ","); siii9532 = a[3]}
/9530.619/ {n = split($0, a, ","); siii9532 = siii9532 + a[3]}
/128135.475/ {n = split($0, a, ","); neii128m = a[3]}
/187129.250/ {n = split($0, a, ","); siii187m = a[3]}
/334795.273/ {n = split($0, a, ","); siii34m = a[3]}
/Detailed Emission Spectrum/{
print " Table 2 Kentucky Benchmark Nebulae" ;
print " Cool 20kK HII region" ;
hb = (hbeta*1e-36)
print " Quantity     ,  Mean,   Model,  Diff%";
printf(" HBeta   E36  ,  4.93, %7.3f, %6.1f\n", hb       , 100*(hb      -4.93)/4.93);
printf(" [NII]   6584+,  0.85, %7.3f, %6.1f\n", nii6584  , 100*(nii6584 -0.85)/0.85);
printf(" [OII]   3727+,  1.18, %7.3f, %6.1f\n", oii3727  , 100*(oii3727 -1.18)/1.18);
printf(" [NeII]  12.8m,  0.31, %7.3f, %6.1f\n", neii128m , 100*(neii128m-0.31)/0.31);
printf(" [SII]   6720+,  0.57, %7.3f, %6.1f\n", sii6720  , 100*(sii6720 -0.57)/0.57);
printf(" [SIII]  18.7m,  0.32, %7.3f, %6.1f\n", siii187m , 100*(siii187m-0.32)/0.32);
printf(" [SIII]  34m  ,  0.52, %7.3f, %6.1f\n", siii34m  , 100*(siii34m -0.52)/0.52);
printf(" [SIII]  9532+,  0.55, %7.3f, %6.1f\n", siii9532 , 100*(siii9532-0.55)/0.55);
suml = (nii6584+oii3727+neii128m+sii6720+siii187m+siii34m+siii9532)*hb
r    = rout*1e-18
printf(" Ltot    E36  , 21.20, %7.3f, %6.1f\n", suml   , 100*(suml     - 21.20)/21.20);
printf(" Tinner  K    , 6793., %7.0f, %6.1f\n", tin    , 100*(tin      - 6793.)/6793.);
printf(" Th+     K    , 6744., %7.0f, %6.1f\n", th     , 100*(th       - 6744.)/6744.);
printf(" <He+>/<H+>   , 0.054, %7.3f, %6.1f\n", he2/h2 , 100*((he2/h2) - 0.054)/0.054);
printf(" Rout    E18  ,  8.96, %7.3f, %6.1f\n\n", r      , 100*(r        - 8.96 )/8.96 );
}
