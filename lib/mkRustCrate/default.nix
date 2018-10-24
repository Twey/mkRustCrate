{ lib, substituteAll, runCommand, stdenv, cargo, rust, bash, jq, remarshal }:
{ name
, version
, src
, dependencies ? []
, devDependencies ? []
, buildDependencies ? []
, doCheck ? false
, buildInputs ? []
, buildProfile ? "release"
, ...} @ args:
let
  args' = builtins.removeAttrs args [];
  makeExecutable = f: runCommand "${f.name}-exec" { }
    ''
      cp ${f} $out
      chmod +x $out
    '';
  und = builtins.replaceStrings ["-"] ["_"];
  wrapper = cmd: makeExecutable (substituteAll {
    src = ./wrapper.sh;
    env = ./env.sh;
    inherit bash cmd;
  });
  transDeps = k: builtins.concatMap (x: x.${k} ++ transDeps k x.${k});
  mkExterns = map (x: "${und x.name}=${x}/lib/lib${und x.name}.rlib");
  mkTrans = map (x: "-L dependency=${x}/lib");
in
stdenv.mkDerivation ({
  inherit buildProfile dependencies devDependencies buildDependencies;
  externs = mkExterns dependencies;
  devExterns = mkExterns devDependencies;
  buildExterns = mkExterns buildDependencies;
  transDependencies = transDeps "dependencies" dependencies;
  transDevDependencies = transDeps "devDependencies" devDependencies;
  transBuildDependencies = transDeps "buildDependencies" buildDependencies;
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
  buildPhase = ". ${./build.sh}";
  installPhase = ". ${./install.sh}";
  RUSTC = wrapper "${rust}/bin/rustc";
  RUSTDOC = wrapper "${rust}/bin/rustdoc";
} // args')
