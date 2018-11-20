shopt -s nullglob

source $utils
source $depinfo

mkdir $out

cd "target/$buildProfile"

hash=$(crate_hash $out)
needs_deps=

for f in *
do
    ext=$(filext $f)
    if [ -x "$f" ] && ! [ -d "$f" ]
    then
        mkdir -p $out/bin
        cp $f $out/bin
        continue
    fi

    case $(filext $f) in
        rlib)
            mkdir -p $out/lib
            cp $f $out/lib
            dest=$out/lib/$(basename $f .rlib).depinfo
            printf 'NIX_RUST_LINK_FLAGS=%q\n' "$NIX_RUST_LINK_FLAGS" > $dest
            for depinfo in build/*/output
            do
                parse_depinfo $depinfo >> $dest
            done
            needs_deps=1
            ;;
        a)
            needs_deps=1
            ;&
        so)
            mkdir -p $out/lib
            cp $f $out/lib
            ;;
        *)
            continue
    esac
done

if [ "$needs_deps" ]
then
    cp -dr ../../deps $out/lib/
fi

if [ -d ../doc ]
then
    mkdir -p $out/share/doc
    cp -r ../doc $out/share/doc/html
fi
