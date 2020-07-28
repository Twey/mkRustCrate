let
  pkgs = import <nixpkgs> { };
in
  pkgs.callPackage ({ callPackage, pkgs, rustChannelOf }:
let
  rustChannel = rustChannelOf {
    date = "2020-03-31";
    channel = "nightly";
  };
  mkRustCrate = callPackage ../../mkRustCrate/lib/mkRustCrate {
    inherit (rustChannel) cargo rust;
  };
  fetchFromCratesIo = callPackage ../../mkRustCrate/lib/fetchFromCratesIo { };
in
rec {
  openssl-sys = mkRustCrate rec {
    name = "openssl-sys";
    version = "0.9.55";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1c05nicx77cfsi4g6vx0sq8blk7075p4wh07hzzy5l6awp5vw0m4";
    };
    buildInputs = [ pkgs.openssl pkgs.pkgconfig ];
    dependencies = [ libc ];
    buildDependencies = [ cc pkg-config autocfg ];
  };

  openssl = mkRustCrate rec {
    name = "openssl";
    version = "0.10.29";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "02vjmz0pm29s6s869q1153pskjdkyd1qqwj8j03linrm3j7609b3";
    };
    dependencies = [ bitflags cfg-if foreign-types lazy_static libc openssl-sys ];
    # devDependencies = [data-encoding hex tempdir];
  };

  bitflags = mkRustCrate rec {
    name = "bitflags";
    version = "1.0.4";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1g1wmz2001qmfrd37dnd5qiss5njrw26aywmg6yhkmkbyrhjxb08";
    };
  };

  cfg-if = mkRustCrate rec {
    name = "cfg-if";
    version = "0.1.10";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "0x52qzpbyl2f2jqs7kkqzgfki2cpq99gpfjjigdp8pwwfqk01007";
    };
  };

  foreign-types = mkRustCrate rec {
    name = "foreign-types";
    version = "0.3.1";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "0rkjl4174b83d1lcdd7rgkb1shhsginjqajzg8wlkqcixhfd4lkn";
    };
    dependencies = [ foreign-types-shared ];
  };

  foreign-types-shared = mkRustCrate rec {
    name = "foreign-types-shared";
    version = "0.1.1";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "0b6cnvqbflws8dxywk4589vgbz80049lz4x1g9dfy4s1ppd3g4z5";
    };
  };

  lazy_static = mkRustCrate rec {
    name = "lazy_static";
    version = "1.1.0";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1da2b6nxfc2l547qgl9kd1pn9sh1af96a6qx6xw8xdnv6hh5fag0";
    };
    dependencies = [ version_check spin ];
  };

  version_check = mkRustCrate rec {
    name = "version_check";
    version = "0.1.5";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1yrx9xblmwbafw2firxyqbj8f771kkzfd24n3q7xgwiqyhi0y8qd";
    };
  };

  spin = mkRustCrate rec {
    name = "spin";
    version = "0.4.9";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1hkb0bkh7n4jnq80axvbfx7p7dxndi7wa3dd9pjcx24x981bsmdn";
    };
  };

  libc = mkRustCrate rec {
    name = "libc";
    version = "0.2.68";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1ypl20mr7rr5c08z9ygl8zf1z63i7mh63dd62jshcdifnwhm37ph";
    };
  };

  pkg-config = mkRustCrate rec {
    name = "pkg-config";
    version = "0.3.14";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "0207fsarrm412j0dh87lfcas72n8mxar7q3mgflsbsrqnb140sv6";
    };
  };

  cc = mkRustCrate rec {
    name = "cc";
    version = "1.0.50";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1di84m338b9c42vfq86g5lyq5s03i0zfvvf59dvb6mr37z063h1d";
    };
  };

  autocfg = mkRustCrate rec {
    name = "autocfg";
    version = "1.0.0";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1hhgqh551gmws22z9rxbnsvlppwxvlj0nszj7n1x56pqa3j3swy7";
    };
  };
}) {}
