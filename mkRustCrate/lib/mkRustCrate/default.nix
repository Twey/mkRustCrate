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
in
stdenv.mkDerivation ({
  inherit buildProfile dependencies devDependencies buildDependencies;
  cargo = "${cargo}/bin/cargo";
  jq = "${jq}/bin/jq";
  remarshal = "${remarshal}/bin/remarshal";
  cargoFilter = ./cargo.jq;
  depinfo = ./depinfo.sh;
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
