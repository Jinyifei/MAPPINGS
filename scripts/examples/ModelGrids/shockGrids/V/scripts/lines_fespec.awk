#
# v1.0.11
#
#
# for reading v5.1.05 + mappings spec.csv output
#
BEGIN{line = 0;
FeV3756 = 0.0;
FeV3783 = 0.0;
FeV3795 = 0.0;
FeV3839 = 0.0;
FeV3891 = 0.0;
FeV3895 = 0.0;
FeV4071 = 0.0;
FeV4143 = 0.0;
FeV4181 = 0.0;
FeV4227 = 0.0;
FeIII4658 = 0.0;
FeIII4702 = 0.0;
FeIII4734 = 0.0;
FeIII4755 = 0.0;
FeIII4769 = 0.0;
FeIII4881 = 0.0;
FeIV4907 = 0.0;
FeVI4972 = 0.0;
FeIII4986 = 0.0;
FeIII4987 = 0.0;
FeIII5011 = 0.0;
FeVI5146 = 0.0;
FeII5159 = 0.0;
FeVI5176 = 0.0;
FeII5262 = 0.0;
FeIII5270 = 0.0;
FeIV6734 = 0.0;
FeIV6740 = 0.0;
NiII7378 = 0.0;
FeII8617 = 0.0;
FeII8892 = 0.0;
FeII9052 = 0.0;
FeII9227 = 0.0;
FeIII9701 = 0.0;
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
/Preshock     nH:/{
     nh=$3
}
/Preshock     B :/{
     b=$4;
}
/Velocity       :/{
     vl=$3;
}
/H-beta  :,/ { n = split($0, a, ","); hbeta = a[4]}
/3755.704/{n = split($0, a, ","); FeV3756 = a[3]}
/3783.221/{n = split($0, a, ","); FeV3783 = a[3]}
/3794.940/{n = split($0, a, ","); FeV3795 = a[3]}
/3839.275/{n = split($0, a, ","); FeV3839 = a[3]}
/3891.281/{n = split($0, a, ","); FeV3891 = a[3]}
/3895.223/{n = split($0, a, ","); FeV3895 = a[3]}
/4071.241/{n = split($0, a, ","); FeV4071 = a[3]}
/4143.153/{n = split($0, a, ","); FeV4143 = a[3]}
/4180.595/{n = split($0, a, ","); FeV4181 = a[3]}
/4227.193/{n = split($0, a, ","); FeV4227 = a[3]}
/4658.051/{n = split($0, a, ","); FeIII4658 = a[3]}
/4701.535/{n = split($0, a, ","); FeIII4702 = a[3]}
/4733.906/{n = split($0, a, ","); FeIII4734 = a[3]}
/4754.687/{n = split($0, a, ","); FeIII4755 = a[3]}
/4769.431/{n = split($0, a, ","); FeIII4769 = a[3]}
/4880.996/{n = split($0, a, ","); FeIII4881 = a[3]}
/4906.557/{n = split($0, a, ","); FeIV4907 = a[3]}
/4972.475/{n = split($0, a, ","); FeVI4972 = a[3]}
/4985.867/{n = split($0, a, ","); FeIII4986 = a[3]}
/4987.210/{n = split($0, a, ","); FeIII4987 = a[3]}
/5011.259/{n = split($0, a, ","); FeIII5011 = a[3]}
/5145.750/{n = split($0, a, ","); FeVI5146 = a[3]}
/5158.792/{n = split($0, a, ","); FeII5159 = a[3]}
/5176.043/{n = split($0, a, ","); FeVI5176 = a[3]}
/5261.633/{n = split($0, a, ","); FeII5262 = a[3]}
/5270.403/{n = split($0, a, ","); FeIII5270 = a[3]}
/6734.416/{n = split($0, a, ","); FeIV6734 = a[3]}
/6739.819/{n = split($0, a, ","); FeIV6740 = a[3]}
/7377.829/{n = split($0, a, ","); NiII7378 = a[3]}
/8616.950/{n = split($0, a, ","); FeII8617 = a[3]}
/8891.929/{n = split($0, a, ","); FeII8892 = a[3]}
/9051.951/{n = split($0, a, ","); FeII9052 = a[3]}
/9226.627/{n = split($0, a, ","); FeII9227 = a[3]}
/9701.273/{n = split($0, a, ","); FeIII9701 = a[3]}
#
END{
rp=nh*vl*vl;
#
printf(" %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %8.4e, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g, %#8.5g\n",
 vl, al0,  al,  b, m, ma, nh, rp, hbeta,
FeV3756,
FeV3783,
FeV3795,
FeV3839,
FeV3891,
FeV3895,
FeV4071,
FeV4143,
FeV4181,
FeV4227,
FeIII4658,
FeIII4702,
FeIII4734,
FeIII4755,
FeIII4769,
FeIII4881,
FeIV4907,
FeVI4972,
FeIII4986,
FeIII4987,
FeIII5011,
FeVI5146,
FeII5159,
FeVI5176,
FeII5262,
FeIII5270,
FeIV6734,
FeIV6740,
NiII7378,
FeII8617,
FeII8892,
FeII9052,
FeII9227);
#
}
