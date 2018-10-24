with import <nixpkgs> { };
stdenv.mkDerivation {
  name = "aoeeuu";
  buildInputs = [rustChannels.nightly.rust openssl pkgconfig];
}
