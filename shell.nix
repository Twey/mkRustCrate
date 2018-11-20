with import <nixpkgs> { };
let
  rustChannel = rustChannelOf {
    date = "2018-11-10";
    channel = "nightly";
  };
in stdenv.mkDerivation {
  name = "aoeeuu";
  buildInputs = [rustChannel.rust openssl pkgconfig];
}
