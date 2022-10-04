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
# eg:
#
# export    mapbase="/opt/local"
# export    mapbase="/usr/local"
# export    mapbase="/Users/ralph/mappings_V"
# export    maplab="${mapbase}/lab"
#
# set to run locally as previously
#
export mapbase="."
export maplab="${mapbase}"
#
set    mappings="$maplab"
setenv MAPPINGS="$maplab"
export mapbin="$maplab"
export MAPBIN="$maplab"
#
alias map="$maplab/map52"
#
# set location for shared gobal mappings data installation,
# uncomment if needed
#
# export mapbase="/opt/local"
#
# export  mappings="$mapbase/share/mappings/"
# export  MAPPINGS="$mapbase/share/mappings/"
#
# export  mapbin="$mapbase/bin"
# export  MAPBIN="$mapbase/bin"
#
# export PATH="$MAPBIN:$PATH"
#
########################################################################
