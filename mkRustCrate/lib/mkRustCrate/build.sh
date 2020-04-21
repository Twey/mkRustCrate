shopt -s nullglob

source $utils

mkdir cargo_home
export CARGO_HOME=$(pwd)/cargo_home

cp $lockFile Cargo.lock
$remarshal -if toml -of json -o Cargo.json Cargo.toml
$jq -f $cargoFilter < Cargo.json \
    | $remarshal -if json -of toml -o Cargo.toml

export CARGO_LINKS=$($jq -r .package.links < Cargo.json)

function run_cargo {
    local cmd=$1
    shift
    $cargo --frozen $cmd -vv --features="$features" "$@"
}

buildFlags=()
if [ "x$buildProfile" = "xrelease" ]
then
    buildFlags+=(--release)
fi

function add_deps {
    local dep_type=$1; shift
    local dep_dir=$1; shift
    local dep_flags=$1; shift
    for dep in ${!dep_type}
    do
        stat $dep/lib/deps/* &>/dev/null \
            && cp -dn $dep/lib/deps/* deps \
            || :
        for depinfo in $dep/lib/*.depinfo
        do
            source $depinfo
        done
        for lib in $dep/lib/*.{rlib,so}
        do
	    local ext=$(filext $lib)
            printf -v$dep_flags "%s --extern %s=%s" \
                "${!dep_flags}" \
                "$(crate_name $dep)" \
                "$dep/lib/lib$(crate_name $dep).$ext"
            local dest=$(basename $lib .$ext)-$(crate_hash $dep).$ext
            copy_or_link "$lib" "$dep_dir/$dest"
        done
    done
}

mkdir deps
add_deps dependencies deps depFlags
RUSTFLAGS="-Ldependency=deps $NIX_RUST_LINK_FLAGS"

link_flags="$NIX_RUST_LINK_FLAGS"
NIX_RUST_LINK_FLAGS=
mkdir build_deps
add_deps buildDependencies build_deps buildDepFlags
BUILD_RUSTFLAGS="-Ldependency=build_deps $NIX_RUST_LINK_FLAGS"
NIX_RUST_LINK_FLAGS="$link_flags"

export RUSTFLAGS
export BUILD_RUSTFLAGS
export depFlags
export buildDepFlags

[ "$doCheck" ] && run_cargo test || :
run_cargo build "${buildFlags[@]}" || exit $?
[ "$doDoc" ] && run_cargo doc || :
