shopt -s nullglob

find -\( -name '.lock' -or -name '*.d' -\) -delete

mkdir -p $out/nix-support
cp metainfo $out/nix-support/

cd "target/$buildProfile"

rm -r */

if stat -t *.rlib *.so *.a &>/dev/null
then
    mkdir -p $out/lib
    mv *.rlib *.so *.a $out/lib/
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

