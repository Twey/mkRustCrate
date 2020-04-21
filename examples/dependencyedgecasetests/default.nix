let
  pkgs = import <nixpkgs> { };
in
  pkgs.callPackage ({ callPackage, rustChannelOf }:
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

      serde_derive = mkRustCrate rec {
        name = "serde_derive";
        version = "1.0.106";
        src = fetchFromCratesIo {
          inherit name version;
          sha256 = "03wq260g5prkgxgfq4yhbmznqm2rr3qmhqah6mh6ddvpmq6axz3p";
        };
        dependencies = [ proc-macro2 quote syn ];
      };

      quote = mkRustCrate rec {
        name = "quote";
        version = "1.0.3";
        src = fetchFromCratesIo {
          inherit name version;
          sha256 = "093chkpg7dc8f86kz0hlxzyfxvbix3xpkmlbhilf0wji228ad35c";
        };
        dependencies = [ proc-macro2 ];
        features = [ "proc-macro" ];
      };

      proc-macro2 = mkRustCrate rec {
        name = "proc-macro2";
        version = "1.0.10";
        src = fetchFromCratesIo {
          inherit name version;
          sha256 = "1sb317587iwq1554s0ksap6718w2l73qa07h2amg3716h8llg6zv";
        };
        dependencies = [ unicode-xid ];
        features = [ "proc-macro" ];
      };

      unicode-xid = mkRustCrate rec {
        name = "unicode-xid";
        version = "0.2.0";
        src = fetchFromCratesIo {
          inherit name version;
          sha256 = "1c85gb3p3qhbjvfyjb31m06la4f024jx319k10ig7n47dz2fk8v7";
        };
      };

      syn = mkRustCrate rec {
        name = "syn";
        version = "1.0.17";
        src = fetchFromCratesIo {
          inherit name version;
          sha256 = "1vd0ixzqffdr6cb49fvwcrhrbd5a9zlrzkifp166fz0ci940ga6h";
        };
        dependencies = [ proc-macro2 unicode-xid quote ];
        features = [ "clone-impls" "derive" "parsing" "printing" "proc-macro" "visit" ];
      };

    }) {}
