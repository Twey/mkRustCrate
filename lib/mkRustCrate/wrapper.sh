#!@bash@/bin/bash

flags="$dependenciesFlags"
[ "x$PROFILE" = xdebug ] && flags+="$devDependenciesFlags" || :
[ "x${OUT_DIR-}" != x ] && flags+="$buildDependenciesFlags" || :

@cmd@ $flags "$@"
