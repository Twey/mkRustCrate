shopt -s nullglob

source $utils

mkdir cargo_home
export CARGO_HOME=$(pwd)/cargo_home

cp $lockFile Cargo.lock
$remarshal -if toml -of json -o Cargo.json Cargo.toml
$jq -f $cargoFilter < Cargo.json \
    | $remarshal -if json -of toml -o Cargo.toml

links=$($jq -r .package.links < Cargo.json)

function run_cargo {
    local cmd=$1
    shift
    $cargo --frozen $cmd --features="$features" "$@"
}

buildFlags=()
if [ "x$buildProfile" = "xrelease" ]
then
    buildFlags+=(--release)
fi

mkdir nix-support
touch nix-support/dependencies
touch nix-support/devDependencies
touch nix-support/buildDependencies

# TODO use this in wrapper.sh instead of traversing the dependency
# tree in Nix
for ty in dependencies devDependencies buildDependencies
do
    for dep in ${!ty}
    do
        source $dep/nix-support/depinfo
        echo $dep >> nix-support/$ty
        cat $dep/nix-support/$ty >> nix-support/$ty
        source $dep/nix-support/depinfo
    done
    sort nix-support/$ty | uniq > nix-support/$ty.uniq
    mv nix-support/$ty{.uniq,}
done

[ "$doCheck" ] && run_cargo test || :
run_cargo build "${buildFlags[@]}"
[ "$doDoc" ] && run_cargo doc || :

$extractDeps target/"$buildProfile"/build/*/output > nix-support/depinfo
substituteInPlace nix-support/depinfo --subst-var-by links $(upper $links)
