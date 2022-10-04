########################################################################
#
# mappings executable alias for constant name in scripts and varying
# build version.  mappings can run wihtout environment variables
# but this can allow for more flexible naming and runtime configuration
#
# syntax for tcshrc and csh family of shells put in your aliases for
# the appropriate shell for both interactive and non-interactive shells
# most commonly .tcshrc or .cshrc
#
# eg:
#
# set    mapbase = "/opt/local"
# set    mapbase = "/usr/local"
# set    mapbase = "/Users/ralph/mappings_V"
# set    maplab  = "${mapbase}/lab"
#
# set to run locally as previously
#
set   mapbase = "."
set   maplab  = "${mapbase}"
#
set    mappings = "$maplab"
setenv MAPPINGS   "$maplab"
set    mapbin = "$maplab"
setenv MAPBIN   "$maplab"
#
 alias map "$maplab/map52"
#
# set location for shared gobal mappings data installation,
# uncomment if needed
#
# set    mappings = "$mapbase/share/mappings/"
# setenv MAPPINGS   "$mapbase/share/mappings/"
#
# set    mapbin = "$mapbase/bin"
# setenv MAPBIN   "$mapbase/bin"
#
# set path = ($mapbin $path)
#
########################################################################
