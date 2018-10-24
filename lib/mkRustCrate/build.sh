source $utils

mkdir cargo_home
export CARGO_HOME=$(pwd)/cargo_home

cp $lockFile Cargo.lock
$remarshal -if toml -of json -o Cargo.json Cargo.toml
$jq -f $cargoFilter < Cargo.json \
    | $remarshal -if json -of toml -o Cargo.toml

links=$($jq -r .package.links < Cargo.json)

cargo="$cargo --frozen"

buildFlags=()
if [ "x$buildProfile" = "xrelease" ]
then
    buildFlags+=(--release)
fi

for dep in $dependencies $devDependencies $buildDependencies
do
    source $dep/nix-support/metainfo
done

if [ "$doCheck" ]
then
    $cargo test
fi

$cargo build "${buildFlags[@]}"
mkdir -p $out/nix-support
$extractDeps target/"$buildProfile"/build/*/output > metainfo
substituteInPlace metainfo --subst-var-by links $(upper $links)

if [ "$doDoc" ]
then
    $cargo doc
fi
