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
  lyalpha  = 0.0
  halpha   = 0.0
  hbeta    = 0.0
  hei5876  = 0.0;
  hei108   = 0.0;
}
/#    <Te>/{line = NR+1}
(NR==line){tin = $2; line = 0}
/Model ended/{liner = NR+1}
(NR==liner){rout = $3}
/ Mass  X,/ {lineion = NR}
(/^ II  /&&(lineion>0)){h2 = $2; he2 = $3; lineion = 0}
/ Average ionic temperatures/ {lineth = NR}
(/^ II   /&&(lineth>0)) {th = $2; lineth = 0}
/H-beta  :,/ { n = split($0, a, ","); hbeta  = a[4]}
/1215.670/ {n = split($0, a, ","); lyalpha   = a[3]}
/5875.664/ {n = split($0, a, ","); hei5876   = a[3]}
/6562.819/ {n = split($0, a, ","); halpha    = a[3]}
/10830.171/ {n = split($0, a, ","); hei108   = a[3]}
/Detailed Emission Spectrum/{
print " MV 5.1 P6 Test 02 [Fe/H] -4.0 metallicity 45kK HII region"
hb = hbeta*1.0e-36
print  " Quantity     ,   P6MV,   Model,  Diff%";
printf(" HBeta   E36  ,  2.383, %7.3f, %6.1f\n", hb        , 100*(hb       -   2.3834)/ 2.3834);
printf(" LyAlpha 1216 , 33.598, %7.3f, %6.1f\n", lyalpha   , 100*(lyalpha  -  33.5980)/33.5980);
printf(" HAlpha  6563 ,  2.963, %7.3f, %6.1f\n", halpha    , 100*(halpha   -   2.9626)/ 2.9626);
printf(" HeI     5876 ,  0.092, %7.3f, %6.1f\n", hei5876   , 100*(hei5876  -   0.0923)/ 0.0923);
printf(" HeI    10830 ,  0.165, %7.3f, %6.1f\n", hei108    , 100*(hei108   -   0.1645)/ 0.1645);
suml =(lyalpha+hei5876+halpha+hei108)
suml = suml*hb   ;
tin  = tin*1.0e-4;
th   = th *1.0e-4;
r    = rout*1e-20;
printf(" Ltot    E36  , 87.751, %7.3f, %6.1f\n", suml   , 100*(suml     -  87.7507)/ 87.7507);
printf(" Tinner  K  E4,  1.623, %7.3f, %6.1f\n", tin    , 100*(tin      -   1.6230)/  1.6230);
printf(" Th+     K  E4,  1.366, %7.3f, %6.1f\n", th     , 100*(th       -   1.3660)/  1.3660);
printf(" <He+>/<H+>   ,  1.039, %7.3f, %6.1f\n", he2/h2 , 100*((he2/h2) -   1.0390)/  1.0390);
printf(" Rout    E20  ,  2.270, %7.3f, %6.1f\n", r      , 100*(r        -   2.2700)/  2.2700);
}
