{ fetchzip }:
{ name, version, ... } @ args:
let
  args' = builtins.removeAttrs args ["name" "version"];
in
fetchzip ({
  name = "${name}-${version}.crate";
  url = "https://crates.io/api/v1/crates/${name}/${version}/download#crate.tar.gz";
} // args')
