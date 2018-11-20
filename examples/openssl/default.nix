{ callPackage, pkgs, rustChannelOf }:
let
  rustChannel = rustChannelOf {
    date = "2018-11-10";
    channel = "nightly";
  };
  cargo = rustChannel.cargo;
  rust = rustChannel.rust;
  mkRustCrate = callPackage ../../mkRustCrate/lib/mkRustCrate { inherit cargo rust; };
  fetchFromCratesIo = callPackage ../../mkRustCrate/lib/fetchFromCratesIo { };
in
rec {
  openssl-sys = mkRustCrate rec {
    name = "openssl-sys";
    version = "0.9.39";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1lraqg3xz4jxrc99na17kn6srfhsgnj1yjk29mgsh803w40s2056";
    };
    buildInputs = [pkgs.openssl pkgs.pkgconfig];
    dependencies = [cc libc pkg-config]; # vcpkg openssl-src
    # devDependencies = [data-encoding hex tempdir];
  };

  gcc = mkRustCrate rec {
    name = "gcc";
    version = "0.3.55";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "18qxv3hjdhp7pfcvbm2hvyicpgmk7xw8aii1l7fla8cxxbcrg2nz";
    };
    dependencies = [];
    # optional: rayon
    # devDependencies = [tempdir];
  };
  
  openssl-src = mkRustCrate rec {
    name = "openssl-src";
    version = "110.0.0";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "07wgsq4mzzxpm99m9hacg034iikvwlsgycvk3qlbg4a4hcaknw1f";
    };
    dependencies = [gcc];
  };

  openssl = mkRustCrate rec {
    name = "openssl";
    version = "0.10.15";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "0fj5g66ibkyb6vfdfjgaypfn45vpj2cdv7d7qpq653sv57glcqri";
    };
    dependencies = [bitflags cfg-if foreign-types lazy_static libc openssl-sys];
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
    version = "0.1.6";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "11qrix06wagkplyk908i3423ps9m9np6c4vbcq81s9fyl244xv3n";
    };
  };

  foreign-types = mkRustCrate rec {
    name = "foreign-types";
    version = "0.3.2";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "105n8sp2djb1s5lzrw04p7ss3dchr5qa3canmynx396nh3vwm2p8";
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
    version = "0.2.43";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "0pshydmsq71kl9276zc2928ld50sp524ixcqkcqsgq410dx6c50b";
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

  vcpkg = mkRustCrate rec {
    name = "vcpkg";
    version = "0.2.6";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "1ig6jqpzzl1z9vk4qywgpfr4hfbd8ny8frqsgm3r449wkc4n1i5x";
    };
  };

  cc = mkRustCrate rec {
    name = "cc";
    version = "1.0.25";
    src = fetchFromCratesIo {
      inherit name version;
      sha256 = "0pd8fhjlpr5qan984frkf1c8nxrqp6827wmmfzhm2840229z2hq0";
    };
  };
}
