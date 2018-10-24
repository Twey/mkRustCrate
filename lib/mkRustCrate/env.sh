depFlags=()
for dep in $externs
do
    depFlags+=(--extern "$dep")
done
for dep in $transDependencies
do
    depFlags+=(-L dependency="$dep"/lib)
done

if [ "x$PROFILE" = xdebug ]
then
    for dep in $devExterns
    do
        depFlags+=(--extern "$dep")
    done
    for dep in $transDevDependencies
    do
        depFlags+=(-L dependency="$dep"/lib)
    done
fi

if [ "x${OUT_DIR-}" != x ]
then
    for dep in $buildExterns
    do
        depFlags+=(--extern "$dep")
    done
    for dep in $transBuildDependencies
    do
        depFlags+=(-L dependency="$dep"/lib)
    done
fi
