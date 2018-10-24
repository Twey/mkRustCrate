for dep in $externs
do
    echo --extern "$dep"
done
for dep in $transDependencies
do
    echo -L dependency="$dep"/lib
done

if [ "x$PROFILE" = xdebug ]
then
    for dep in $devExterns
    do
        echo --extern "$dep"
    done
    for dep in $transDevDependencies
    do
        echo -L dependency="$dep"/lib
    done
fi

if [ "x${OUT_DIR-}" != x ]
then
    for dep in $buildExterns
    do
        echo --extern "$dep"
    done
    for dep in $transBuildDependencies
    do
        echo -L dependency="$dep"/lib
    done
fi
