#
# v1.0.11
#
#
# for reading v5.1.05 + mappings spec.csv output
#
BEGIN {

  line     = 0;

  al0      = 0.0;
  al       = 0.0;
  b        = 0.0;
  nh       = 0.0;
  vl       = 0.0;

  halpha   = 0.0;
  hei5876  = 0.0;
  heii4686 = 0.0;
#
  ni       = 0.0;
  nii      = 0.0;
  nii5755  = 0.0;
  nii6584  = 0.0;
#
  oi       = 0.0;
  oi5577   = 0.0;
  oi6300   = 0.0;
  oii      = 0.0;
  oii3726  = 0.0;
  oii3729  = 0.0;
  oii7319  = 0.0;
  oii7330  = 0.0;
  oiii     = 0.0;
  oiii4363 = 0.0;
  oiii5007 = 0.0;
#
  caii     = 0.0;
  mgi      = 0.0;
  neiii    = 0.0;
  nev      = 0.0;
#
  sii      = 0.0;
  sii6716  = 0.0;
  sii6731  = 0.0;
  siib     = 0.0;
#
  siii     = 0.0;
  siii9530 = 0.0;
  siii6312 = 0.0;
#
  hp2      = 0.0;
  np2      = 0;
}
/ Output:/{print " "$2}
/Run  :/{
    gsub(/^[ \t]+|[ \t]+$/, "")
    n=split($0, a, ":");
    run=a[2];
}
/Proto Mag Alpha /{
     al0=$5;
}
/Preshock Mag Alpha /{
     al=$5;
}
/Preshock Mach Number/{
     m=$5;
}
/Preshock Alfven Mach Number/{
     ma=$6;
}
/Preshock     B :/{
     b=$4;
}
/Preshock     nH:/{
     nh=$3;
}
/Velocity       :/{
     vl=$3;
}
/H-beta  :,/ { n = split($0, a, ","); hbeta = a[4]}
/Two-Photon Continuum/ {np2=NR+2}
(NR==np2){ n = split($0, a, ","); hp2      = a[2]}
#
/3345.821/{n = split($0, a, ","); nev      = a[3]}
/3425.881/{n = split($0, a, ","); nev      = nev  + a[3]}
/3726.032/{n = split($0, a, ","); oii      = a[3];oii3726 = a[3]}
/3728.815/{n = split($0, a, ","); oii      = oii  + a[3];oii3729 = a[3]}
/3868.764/{n = split($0, a, ","); neiii    = a[3]}
/3967.471/{n = split($0, a, ","); neiii    = neiii  + a[3]}
/3933.663/{n = split($0, a, ","); caii     = a[3]}
#/3968.469/{n = split($0, a, ","); caii     = caii  + a[3]}
#
/4068.600/{n = split($0, a, ","); siib     = a[3]; sii4068 = a[3]}
/4076.349/{n = split($0, a, ","); siib     = siib  + a[3]; sii4076 = a[3]}
#
/4363.209/{n = split($0, a, ","); oiii4363 = a[3]}
/4566.837/{n = split($0, a, ","); mgi      = a[3]}
/4685.702/{n = split($0, a, ","); heii4686 = a[3]}
/4958.911/{n = split($0, a, ","); oiii     = a[3]}
/5006.843/{n = split($0, a, ","); oiii     = oiii+a[3]; oiii5007 = a[3]}
#
/5197.902/{n = split($0, a, ","); ni       = a[3]}
/5200.257/{n = split($0, a, ","); ni       = ni   +   a[3]}
#
/5577.339/{n = split($0, a, ","); oi5577   = a[3]}
/5754.595/{n = split($0, a, ","); nii5755  = a[3]}
#
/5875.614/{n = split($0, a, ","); hei5876 = a[3]}
/5875.615/{n = split($0, a, ","); hei5876 = hei5876 + a[3]}
/5875.625/{n = split($0, a, ","); hei5876 = hei5876 + a[3]}
/5875.664/{n = split($0, a, ","); hei5876 = hei5876 + a[3]}
/5875.966/{n = split($0, a, ","); hei5876 = hei5876 + a[3]}
#
/6300.304/{n = split($0, a, ","); oi6300  = a[3]; oi  = a[3]}
/6363.776/{n = split($0, a, ","); oi      = oi  +  a[3]}
/6312.063/{n = split($0, a, ","); siii6312 = a[3]}
/6548.052/{n = split($0, a, ","); nii     = a[3]}
/6562.819/{n = split($0, a, ","); halpha  = a[3]}
/6583.454/{n = split($0, a, ","); nii     = nii + a[3]; nii6584 = a[3]}
/6716.440/{n = split($0, a, ","); sii     = a[3]; sii6716 = a[3]; }
/6730.816/{n = split($0, a, ","); sii     = sii + a[3]; sii6731 = a[3]; }
#
/7318.923/{n = split($0, a, ","); oii7319 = a[3]}
/7319.989/{n = split($0, a, ","); oii7319 = oii7319  + a[3]}
/7329.665/{n = split($0, a, ","); oii7330 = a[3]}
/7330.735/{n = split($0, a, ","); oii7330 = oii7330  + a[3]}
#
/9068.620/{n = split($0, a, ","); siii    = a[3]}
/9530.619/{n = split($0, a, ","); siii    = siii + a[3]; siii9530 =  a[3]}
END{
rp=nh*vl*vl;
#
printf("  %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %8.4e, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g\n",
 vl, al0,  al,  b, m, ma, nh, rp, hbeta, hp2, halpha, hei5876, heii4686,
 ni , nii5755, nii6584 ,  nii ,
 oi5577, oi6300, oi ,
 oii, oii3726, oii3729, oii7319+oii7330,
 oiii4363,oiii5007,oiii,
 neiii, nev, mgi,
 sii,sii6716, sii6731,siib,
 siii6312,  siii9530, siii,
 caii);
}
