#
# Useage: to make MAPPINGS Auxillary exes
# > make
#
# v2.0
#
SHELL=/bin/sh
vpath %.c %.h zlib zls ccl

all:
	@make compile
	@make clean
	@make install

compile:
	cd blur; $(MAKE) compile
	cd lines; $(MAKE) compile
	cd red; $(MAKE) compile

install:
	cd blur; $(MAKE) install
	cd lines; $(MAKE) install
	cd red; $(MAKE) install

clean:
	cd blur; $(MAKE) clean
	cd lines; $(MAKE) clean
	cd red; $(MAKE) clean

distclean:
	cd blur; $(MAKE) distclean
	cd lines; $(MAKE) distclean
	cd red; $(MAKE) distclean
	@make uninstall

uninstall:
	cd blur; $(MAKE) uninstall
	cd lines; $(MAKE) uninstall
	cd red; $(MAKE) uninstall

