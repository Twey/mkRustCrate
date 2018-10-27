shopt -s nullglob

find -\( -name '.lock' -or -name '*.d' -\) -delete

mkdir $out
cp -r nix-support $out/

cd "target/$buildProfile"

rm -r */

if stat -t *.rlib *.so *.a &>/dev/null
then
    mkdir -p $out/lib
    mv *.rlib *.so *.a $out/lib/
else
    echo '' > $out/nix-support/dependencies
    echo '' > $out/nix-support/devDependencies
    echo '' > $out/nix-support/buildDependencies
fi

if stat -t * &>/dev/null
then
    mkdir -p $out/bin
    mv * $out/bin/
fi

if [ -d ../doc ]
then
    mkdir -p $out/share/doc
    cp -r ../doc $out/share/doc/html
fi

