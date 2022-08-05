Standalone optxagnf AGN spectrum model
v1.0.0

Building: builds with macports gfortran or f2c/gcc

Use Makefile.f2c (f2c/gcc)  or Makefile.for (gfortran)

>cp Makefile.for Makefile

creates ./agn

Use:

edit parameters in agn.conf as needed
run agn:

./agn > output.txt

and create spectrum in output.txt.

It is possible to use a template agn.conf and run an grid of
models with the runnsl.sh or runbsl.sh scripts.

