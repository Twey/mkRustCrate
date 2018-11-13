{ lib, substituteAll, runCommand, stdenv, cargo, rust, bash, jq, remarshal }:
{ name
, version
, src
, dependencies ? []
, devDependencies ? []
, buildDependencies ? []
, features ? ["default"]
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
  wrapper = cmd: substituteAll {
    src = ./wrapper.sh;
    inherit bash cmd;
  };
  transDeps = k: builtins.concatMap (x: x.${k} ++ transDeps k x.${k});
  mkExterns = xs: builtins.concatStringsSep " " (map (x: if x == null then "" else
    "--extern ${und x.name}=${x}/lib/lib${und x.name}.rlib") xs);
  mkTrans = xs: builtins.concatStringsSep " " (map (x: "-L dependency=${x}/lib") xs);
  depFlags = k: v: mkExterns v + " " + mkTrans (transDeps k v);
in
stdenv.mkDerivation ({
  inherit buildProfile dependencies devDependencies buildDependencies;
  dependenciesFlags = depFlags "dependencies" dependencies;
  devDependenciesFlags = depFlags "devDependencies" devDependencies;
  buildDependenciesFlags = depFlags "buildDependencies" buildDependencies;
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
  RUSTC = wrapper "${rust.rustc}/bin/rustc";
  RUSTDOC = wrapper "${rust.rustc}/bin/rustdoc";
} // args')
