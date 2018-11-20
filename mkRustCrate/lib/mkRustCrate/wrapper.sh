#!@bash@/bin/bash

source $utils

args=("$@")
for i in ${!args[@]}
do
    if [ "x${args[$i]::9}" = "xmetadata=" ]
    then
        args[$i]=metadata=$(crate_hash $out)
    fi
done

env @cmd@ $depFlags "${args[@]}"
