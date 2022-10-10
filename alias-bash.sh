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
# used for data/ and atmos/. Not used for abund/ yet
#
# set general mappings area then specify data/ location & mappings exe
#
# or globally installed in system base area or other user area:
# up to user to use sudo make install su install options in make
# or create other locations
#
# mapbase="/usr/local"
# export MAPDATA="$mapbase/share/mappings/"
# export MAPBIN="$mapbase/bin"
#
# add bin area to global path, same for all
#
# export PATH="$MAPBIN:$PATH"
#
# standard alias for all exe version names
#
# alias map="map52"
#
# here set to run in lab as previously, change username as needed
#
mapbase="~"
export MAPDATA="$mapbase/lab"
export MAPBIN="$mapbase/lab"
#
export PATH="$MAPBIN:$PATH"
#
alias map="map52"
#
########################################################################
