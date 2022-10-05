########################################################################
#
# mappings executable alias for constant name in scripts and varying
# build version.  mappings can run wihtout environment variables
# but this can allow for more flexible naming and runtime configuration
#
# Syntax for sh, bash and zsh family of shells put in your aliases for
# the appropriate shell for both interactive and non-interactive shells
# most commonly .bashrc/.profile as appropriate or .zshrc
#
########################################################################
#
# set general mappings area then specify data/ location & mappings exe
#
# local to std mappings_V/lab change user name as needed
#
# set mapbase = "/Users/ralph/mappings_V"
# setenv MAPDATA  "$mapbase/lab"
# set mapbin  = "$mapbase/lab"
# setenv MAPBIN "$mapbin"
#
# or globally installed in system base area or other user area:
# up to user to use sudo make install su install options in make
# or create other locations
#
# set mapbase = "/usr/local"
# setenv MAPDATA  "$mapbase/share/mappings"
# set mapbin  = "$mapbase/bin"
# setenv MAPBIN "$mapbin"
#
# add bin area to global path, same for all
#
# set path = ($mapbin $path)
#
# standard alias for all exe version names
#
# alias map "map52"
#
 set mapbase =  "/Users/ralph/mappings_V"
 setenv MAPDATA "$mapbase/lab"
 set mapbin  =  "$mapbase/lab"
 setenv MAPBIN  "$mapbin"
 set path = ($mapbin $path)
#
 alias map "map52"
#
########################################################################
