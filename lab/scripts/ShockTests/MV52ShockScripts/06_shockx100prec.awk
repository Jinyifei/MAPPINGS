#
# v5.1.21dev
#
BEGIN{line = 0;
  lineion= 0;
  hbeta     = 0.0
  lyalpha   = 0.0;
  hei5876   = 0.0;
  heii4686  = 0.0;
  cii2326   = 0.0;
  ciii1909  = 0.0;
  civ1549   = 0.0;
  ni5200    = 0.0;
  nii6584   = 0.0;
  niii1749  = 0.0;
  niii57m   = 0.0;
  oi6300    = 0.0;
  oii3727   = 0.0;
  oiii4363  = 0.0;
  oiii5007  = 0.0;
  oiii518m  = 0.0;
  oiv26m    = 0.0;
  neiii3869 = 0.0;
  neiii155m = 0.0;
  neiv2423  = 0.0;
  mgii2798  = 0.0;
  mgiv45m   = 0.0;
  slii2335  = 0.0;
  slii348m  = 0.0;
  sliii1892 = 0.0;
  sliv1397  = 0.0;
  sii6720   = 0.0;
  siii9532  = 0.0;
  siii187m  = 0.0;
  siv105m   = 0.0;
}
/Lambda(A)/ {lineth = NR}
/H-beta  :,/ { n = split($0, a, ","); hbeta       = a[4]}
/1215.670/ {n = split($0, a, ",");    lyalpha     = a[3]}
/1238.821/ {n = split($0, a, ",");    nv1240      = a[3]}
/1242.804/ {n = split($0, a, ",");    nv1240      = nv1240+a[3]}
/1399.776/ {n = split($0, a, ",");    oiv1400     = a[3]}
/1401.163/ {n = split($0, a, ",");    oiv1400     = oiv1400+a[3]}
/1393.755/ {n = split($0, a, ",");    siiv1397    = a[3]}
/1402.770/ {n = split($0, a, ",");    siiv1397    = siiv1397+a[3]}
/1404.806/ {n = split($0, a, ",");    oiv1406     = a[3]}
/1407.384/ {n = split($0, a, ",");    oiv1406     = oiv1406+a[3]}
/1483.321/ {n = split($0, a, ",");    niv1485     = a[3]}
/1486.496/ {n = split($0, a, ",");    niv1485     = niv1485+a[3]}
/1548.187/ {n = split($0, a, ",");    civ1549     = a[3]}
/1550.772/ {n = split($0, a, ",");    civ1549     = civ1549 + a[3]}
/1660.809/ {n = split($0, a, ",");    oiii1663    = a[3]}
/1666.150/ {n = split($0, a, ",");    oiii1663    = oiii1663 + a[3]}
/1746.823/ {n = split($0, a, ",");    niii1749    = a[3]}
/1748.646/ {n = split($0, a, ",");    niii1749    = niii1749+a[3]}
/1749.674/ {n = split($0, a, ",");    niii1749    = niii1749+a[3]}
/1752.160/ {n = split($0, a, ",");    niii1749    = niii1749+a[3]}
/1753.995/ {n = split($0, a, ",");    niii1749    = niii1749+a[3]}
/1806.000/ {n = split($0, a, ",");    mgvi1806    = a[3]}
/1806.424/ {n = split($0, a, ",");    mgvi1806    = mgvi1806 + a[3]}
/1882.707/ {n = split($0, a, ",");    sliii1892   = a[3]}
/1892.029/ {n = split($0, a, ",");    sliii1892   = sliii1892 + a[3]}
/1906.683/ {n = split($0, a, ",");    ciii1909    = a[3]}
/1908.734/ {n = split($0, a, ",");    ciii1909    = ciii1909 + a[3]}
/2323.560/ {n = split($0, a, ",");    cii2326     = a[3]}
/2324.695/ {n = split($0, a, ",");    cii2326     = cii2326 + a[3]}
/2325.408/ {n = split($0, a, ",");    cii2326     = cii2326 + a[3]}
/2326.989/ {n = split($0, a, ",");    cii2326     = cii2326 + a[3]}
/2328.127/ {n = split($0, a, ",");    cii2326     = cii2326 + a[3]}
/2328.517/ {n = split($0, a, ",");    slii2335    = a[3]}
/2334.407/ {n = split($0, a, ",");    slii2335    = slii2335+a[3]}
/2334.605/ {n = split($0, a, ",");    slii2335    = slii2335+a[3]}
/2344.202/ {n = split($0, a, ",");    slii2335    = slii2335+a[3]}
/2350.172/ {n = split($0, a, ",");    slii2335    = slii2335+a[3]}
/2421.810/ {n = split($0, a, ",");    neiv2423    = a[3]}
/2424.422/ {n = split($0, a, ",");    neiv2423    = neiv2423 + a[3]}
/2790.777/ {n = split($0, a, ",");    mgii2798    = a[3]}
/2795.528/ {n = split($0, a, ",");    mgii2798    = mgii2798+a[3]}
/2797.930/ {n = split($0, a, ",");    mgii2798    = mgii2798+a[3]}
/2797.998/ {n = split($0, a, ",");    mgii2798    = mgii2798+a[3]}
/2802.705/ {n = split($0, a, ",");    mgii2798    = mgii2798+a[3]}
/3726.032/ {n = split($0, a, ",");    oii3727     = a[3]}
/3728.815/ {n = split($0, a, ",");    oii3727     = oii3727 + a[3]}
/3868.764/ {n = split($0, a, ",");    neiii3869   = a[3]}
/3967.471/ {n = split($0, a, ",");    neiii3967   = a[3]}
/4363.209/ {n = split($0, a, ",");    oiii4363    = a[3]}
/4685.702/ {n = split($0, a, ",");    heii4686    = a[3]}
/4958.911/ {n = split($0, a, ",");    oiii4959    = a[3]}
/5006.843/ {n = split($0, a, ",");    oiii5007    = a[3]}
/5197.901/ {n = split($0, a, ",");    ni5200      = a[3]}
/5200.257/ {n = split($0, a, ",");    ni5200      = ni5200 + a[3]}
/5754.595/ {n = split($0, a, ",");    nii5755     = a[3]}
/5875.664/ {n = split($0, a, ",");    hei5876     = a[3]}
/6300.304/ {n = split($0, a, ",");    oi6300      = a[3]}
/6363.776/ {n = split($0, a, ",");    oi6364      = a[3]}
/6312.063/ {n = split($0, a, ",");    siii6312    = a[3]}
/6548.052/ {n = split($0, a, ",");    nii6548     = a[3]}
/6583.454/ {n = split($0, a, ",");    nii6584     = a[3]}
/6716.440/ {n = split($0, a, ",");    sii6716     = a[3]}
/6730.816/ {n = split($0, a, ",");    sii6731     = a[3]}
/7318.923/ {n = split($0, a, ",");    oii7319     = a[3]}
/7319.989/ {n = split($0, a, ",");    oii7319     = oii7319 + a[3]}
/7329.665/ {n = split($0, a, ",");    oii7330     = a[3]}
/7330.735/ {n = split($0, a, ",");    oii7330     = oii7330 + a[3]}
/9068.620/ {n = split($0, a, ",");    siii9069    = a[3]}
/9530.619/ {n = split($0, a, ",");    siii9531    = a[3]}
/16435.527/ {n = split($0, a, ",");   feii16435   = a[3]}
/69852.746/ {n = split($0, a, ",");   arii6985m   =  a[3]}
/76522.804/ {n = split($0, a, ",");   nevi7652m   = a[3]}
/105104.947/ {n = split($0, a, ",");  siv1051m    = a[3]}
/128135.475/ {n = split($0, a, ",");  neii1281m   = a[3]}
/155550.993/ {n = split($0, a, ",");  neiii1555m   = a[3]}
/179360.294/ {n = split($0, a, ",");  feii1793m   = a[3]}
/187129.250/ {n = split($0, a, ",");  siii1871m    = a[3]}
/258933.195/ {n = split($0, a, ",");  oiv2589m      = a[3]}

END{
print  " MV 5.2 Shock Test 02: 100km/s Precursor"
print  " Quantity      ,   MVS5,   Model,  Diff%"
hb = hbeta*1e6
printf(" HB  e-06 4861 , 0.6265, %7.4f, %6.1f\n", hb,         100*(hb          - 6.26531e-01)/ 6.26531e-01);
printf(" Lya      1215 , 274.29, %7.2f, %6.1f\n", lyalpha,    100*(lyalpha     - 2.74288e+02)/ 2.74288e+02);
printf(" HeI      5876 ,  0.008, %7.3f, %6.1f\n", hei5876,    100*( hei5876    - 8.44830e-03)/ 8.44830e-03);
printf(" CII      2326 ,  4.058, %7.3f, %6.1f\n", cii2326,    100*( cii2326    - 4.05802e+00)/ 4.05802e+00);
printf(" CIII     1909 ,  1.036, %7.3f, %6.1f\n", ciii1909,   100*( ciii1909   - 1.03615e+00)/ 1.03615e+00);
printf(" NI       5200 ,  2.013, %7.3f, %6.1f\n", ni5200,     100*( ni5200     - 2.01321e+00)/ 2.01321e+00);
printf(" NII      5755 ,  0.065, %7.3f, %6.1f\n", nii5755,    100*( nii5755    - 6.54057e-02)/ 6.54057e-02);
printf(" NII      6548 ,  0.772, %7.3f, %6.1f\n", nii6548,    100*( nii6548    - 7.71698e-01)/ 7.71698e-01);
printf(" NII      6584 ,  2.270, %7.3f, %6.1f\n", nii6584,    100*( nii6584    - 2.27047e+00)/ 2.27047e+00);
printf(" OI       6300 ,  5.247, %7.3f, %6.1f\n", oi6300,     100*( oi6300     - 5.24659e+00)/ 5.24659e+00);
printf(" OII      3727 ,  3.602, %7.3f, %6.1f\n", oii3727,    100*( oii3727    - 3.60200e+00)/ 3.60200e+00);
printf(" OII      7319 ,  0.058, %7.3f, %6.1f\n", oii7319,    100*( oii7319    - 5.84882e-02)/ 5.84882e-02);
printf(" OII      7330 ,  0.047, %7.3f, %6.1f\n", oii7330,    100*( oii7330    - 4.73975e-02)/ 4.73975e-02);
printf(" NeII   12.81m ,  0.183, %7.3f, %6.1f\n", neii1281m,  100*( neii1281m  - 1.83017e-01)/ 1.83017e-01);
printf(" NeIII  15.55m ,  0.012, %7.3f, %6.1f\n", neiii1555m, 100*( neiii1555m - 1.24211e-02)/ 1.24211e-02);
printf(" MgII     2798 , 18.602, %7.3f, %6.1f\n", mgii2798,   100*( mgii2798   - 1.86020e+01)/ 1.86020e+01);
printf(" SiIII    1892 ,  0.011, %7.3f, %6.1f\n", sliii1892,  100*( sliii1892  - 1.11988e-02)/ 1.11988e-02);
printf(" SiIII    2335 ,  1.049, %7.3f, %6.1f\n", slii2335,   100*( slii2335   - 1.04919e+00)/ 1.04919e+00);
printf(" SiIII  18.71m ,  0.065, %7.3f, %6.1f\n", siii1871m,  100*( siii1871m  - 6.50858e-02)/ 6.50858e-02);
printf(" SII      6716 ,  3.221, %7.3f, %6.1f\n", sii6716,    100*( sii6716    - 3.22135e+00)/ 3.22135e+00);
printf(" SII      6731 ,  2.243, %7.3f, %6.1f\n", sii6731,    100*( sii6731    - 2.24337e+00)/ 2.24337e+00);
printf(" SIII     6312 ,  0.010, %7.3f, %6.1f\n", siii6312,   100*( siii6312   - 1.02539e-02)/ 1.02539e-02);
printf(" SIII     9069 ,  0.076, %7.3f, %6.1f\n", siii9069,   100*( siii9069   - 7.55635e-02)/ 7.55635e-02);
printf(" SIII     9531 ,  0.190, %7.3f, %6.1f\n", siii9531,   100*( siii9531   - 1.89812e-01)/ 1.89812e-01);
printf(" ArII   6.985m ,  0.026, %7.3f, %6.1f\n", arii6985m,  100*( arii6985m  - 2.61226e-02)/ 2.61226e-02);
printf(" FeII   1.643m ,  0.833, %7.3f, %6.1f\n", feii16435,  100*( feii16435  - 8.32970e-01)/ 8.32970e-01);
printf(" FeII   17.93m ,  0.180, %7.3f, %6.1f\n", feii1793m,  100*( feii1793m  - 1.80274e-01)/ 1.80274e-01);
suml = (lyalpha+nv1240+oiv1400+siiv1397+oiv1406+niv1485+civ1549)
suml = suml+(oiii1663+niii1749+mgvi1806+sliii1892+ciii1909+cii2326)
suml = suml+(slii2335+neiv2423+mgii2798+oii3727+neiii3869+neiii3967)
suml = suml+(oiii4363+heii4686+oiii4959+oiii5007+ni5200+nii5755)
suml = suml+(hei5876+oi6300+siii6312+nii6548+nii6584+sii6716+sii6731)
suml = suml+(oii7319+oii7330+siii9069+siii9531+feii16435+arii6985m)
suml = suml+(nevi7652m+siv1051m+neii1281m+neiii1555m)
suml = suml+(feii1793m+siii1871m+oiv2589m)
suml = suml*hb;
printf(" Ltot  e-06    , 200.62, %7.2f, %6.1f\n", suml   , 100*(suml     - 2.00620e+02)/2.00620e+02);
}
