{ lib, substituteAll, runCommand, stdenv, cargo, rust, bash, jq, remarshal }:
{ name
, version
, src
, dependencies ? []
, devDependencies ? []
, buildDependencies ? []
, features ? []
, doCheck ? false
, buildInputs ? []
, buildProfile ? "release"
, ...} @ args:
let
  args' = builtins.removeAttrs args ["features"];
  makeExecutable = f: runCommand "${f.name}-exec" { }
    ''
      cp ${f} $out
      chmod +x $out
    '';
  und = builtins.replaceStrings ["-"] ["_"];
  wrapper = cmd: makeExecutable (substituteAll {
    src = ./wrapper.sh;
    inherit bash cmd;
  });
  transDeps = k: builtins.concatMap (x: x.${k} ++ transDeps k x.${k});
  mkExterns = xs: builtins.concatStringsSep " " (map (x: if x == null then "" else
    "--extern ${und x.name}=${x}/lib/lib${und x.name}.rlib") xs);
  mkTrans = xs: builtins.concatStringsSep " " (map (x: "-L dependency=${x}/lib") xs);
in
stdenv.mkDerivation ({
  inherit buildProfile dependencies devDependencies buildDependencies;
  dependenciesFlags = mkExterns dependencies
    + " " + mkTrans (transDeps "dependencies" dependencies);
  devDependenciesFlags = mkExterns devDependencies
    + " " + mkTrans (transDeps "devDependencies" devDependencies);
  buildDependenciesFlags = mkExterns buildDependencies
    + " " + mkTrans (transDeps "buildDependencies" buildDependencies);
  cargo = "${cargo}/bin/cargo";
  jq = "${jq}/bin/jq";
  remarshal = "${remarshal}/bin/remarshal";
  cargoFilter = ./cargo.jq;
  extractDeps = ./extract-deps.sh;
  utils = ./util.sh;
  lockFile = substituteAll {
    src = ./Cargo.lock;
    crateName = name;
    crateVersion = version;
  };
  features = builtins.concatStringsSep " " features;
  buildPhase = ". ${./build.sh}";
  installPhase = ". ${./install.sh}";
  RUSTC = wrapper "${rust}/bin/rustc";
  RUSTDOC = wrapper "${rust}/bin/rustdoc";
} // args')
