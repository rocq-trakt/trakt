{
  inputs = {
    # NOTE: Switch to nixos-26.05 when it will be published
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      flake-parts,
      self,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      flake = {
        lib = nixpkgs.lib.extend (
          self: _: {
            mkTrakt =
              let
                isVersion = str: builtins.match "[0-9]+(\\.[0-9]+)*" str != null;

                mkFmt = self.replaceStrings [ "." ] [ "_" ];

                mkRocqPackages =
                  pkgs: version:
                  if isVersion version then
                    pkgs."rocqPackages_${mkFmt version}"
                  else
                    pkgs.rocqPackages.overrideScope (
                      _: prev: {
                        rocq-core = prev.rocq-core.override { inherit version; };
                      }
                    );

                mkStdlib = rocqPackages: version: rocqPackages.stdlib.override { inherit version; };
                mkRocqElpi = rocqPackages: version: rocqPackages.rocq-elpi.override { inherit version; };
              in
              pkgs:
              {
                rocq,
                stdlib,
                rocq-elpi,
              }:
              let
                rocqPackages = mkRocqPackages pkgs rocq;
              in
              {
                name = "trakt-${mkFmt rocq}-${mkFmt stdlib}-${mkFmt rocq-elpi}";
                value = rocqPackages.trakt.override {
                  stdlib = mkStdlib rocqPackages stdlib;
                  rocq-elpi = mkRocqElpi rocqPackages rocq-elpi;
                };
              };
          }
        );

        overlays.default = (
          _: pkgs:
          let
            trakt =
              {
                mkRocqDerivation,
                rocqPackages,
                stdlib,
                rocq-elpi,
                ...
              }:
              mkRocqDerivation {
                pname = "trakt";

                src = ./.;
                version = "nightly";

                opam-name = "rocq-trakt";
                useDune = true;

                nativeBuildInputs = [
                  pkgs.git
                ];

                propagatedBuildInputs = [
                  stdlib
                  rocq-elpi
                ];

                meta = {
                  description = "A generic goal preprocessing tool for proof automation tactics in Rocq";
                  homepage = "https://github.com/rocq-trakt/trakt";
                  license = pkgs.lib.licenses.lgpl3Plus;
                };
              };

            mkRocqPackages =
              base:
              base.overrideScope (
                self: _: {
                  trakt = self.callPackage trakt { };
                }
              );
          in
          {
            rocqPackages = mkRocqPackages pkgs.rocqPackages;

            rocqPackages_9_0 = mkRocqPackages pkgs.rocqPackages_9_0;
            rocqPackages_9_1 = mkRocqPackages pkgs.rocqPackages_9_1;
            rocqPackages_9_2 = mkRocqPackages pkgs.rocqPackages_9_2;
          }
        );
      };

      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        rec {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };

          packages = {
            default = pkgs.rocqPackages.trakt;

            trakt = pkgs.rocqPackages.trakt;

            example =
              let
                # NOTE: Use `mathcomp-zify` when available in Nix's `RocqPackages`
                mkMathcompDrv =
                  name: propagatedBuildInputs:
                  pkgs.rocqPackages.mkRocqDerivation rec {
                    inherit propagatedBuildInputs;

                    owner = "math-comp";
                    repo = "math-comp";

                    pname = "mathcomp-${name}";
                    preBuild = "cd ${name}";

                    version = "mathcomp-2.5.0";
                    release.${version}.sha256 = "sha256-M/6IP4WhTQ4j2Bc8nXBXjSjWO08QzNIYI+a2owfOh+8=";
                  };

                boot = mkMathcompDrv "boot" [ pkgs.rocqPackages.hierarchy-builder ];
                order = mkMathcompDrv "order" [ boot ];
                fingroup = mkMathcompDrv "fingroup" [ boot ];
                algebra = mkMathcompDrv "algebra" [
                  order
                  fingroup
                ];

                zify = pkgs.rocqPackages.mkRocqDerivation rec {
                  owner = "math-comp";
                  repo = "mczify";

                  pname = "zify";
                  propagatedBuildInputs = [
                    algebra
                    pkgs.rocqPackages.stdlib
                  ];

                  preBuild = ''
                    sed -i -e 's/coq_makefile/rocq makefile/g' Makefile
                  '';

                  version = "1.6.0+2.3+8.18";
                  release.${version}.sha256 = "sha256-rI5ZWtgO0a2sxCVChTdASxWxhgYEbM4OhC0dnSMRzZ8=";
                };
              in
              pkgs.rocqPackages.mkRocqDerivation {
                pname = "trakt-example";
                opam-name = "rocq-trakt-example";

                src = ./example;
                version = "nightly";
                useDune = true;

                propagatedBuildInputs = [
                  pkgs.rocqPackages.trakt
                  zify
                ];
              };
          };

          checks =
            let
              # NOTE: Waiting the version 3.23 of Dune for Rocq 9.0 builds
              # See: https://github.com/ocaml/dune/pull/14093
              duneOverlay = final: prev: {
                rocqPackages_9_0 = prev.rocqPackages_9_0.overrideScope (
                  _: _: {
                    dune = prev.ocamlPackages.dune_3.overrideAttrs rec {
                      version = "3.23.0-alpha2";

                      src = pkgs.fetchurl {
                        url = "https://github.com/ocaml/dune/releases/download/3.23.0_alpha2/dune-3.23.0.alpha2.tbz";
                        hash = "sha256-gYLRz/nYqn+JAs1QOTRyq9lPSTHbzHNznLEqBGoYTZM=";
                      };
                    };
                  }
                );
              };

              pkgs = import nixpkgs {
                inherit system;
                overlays = [
                  duneOverlay
                  self.overlays.default
                ];
              };

              combinaison = [
                {
                  rocq = "9.0";
                  stdlib = "9.0";
                  rocq-elpi = "3.3.0";
                }
                {
                  rocq = "9.0";
                  stdlib = "9.1";
                  rocq-elpi = "3.3.0";
                }
                {
                  rocq = "9.1";
                  stdlib = "9.0";
                  rocq-elpi = "3.3.0";
                }
                {
                  rocq = "9.1";
                  stdlib = "9.1";
                  rocq-elpi = "3.3.0";
                }
                {
                  rocq = "9.2";
                  stdlib = "9.1";
                  rocq-elpi = "3.3.0";
                }
              ];
            in
            self.lib.listToAttrs (map (self.lib.mkTrakt pkgs) combinaison)
            // {
              test = pkgs.rocqPackages.mkRocqDerivation {
                pname = "trakt-test";
                opam-name = "rocq-trakt-test";

                src = ./test;
                version = "nightly";
                useDune = true;

                propagatedBuildInputs = [
                  pkgs.rocqPackages.trakt
                ];
              };
            };

          formatter = pkgs.nixfmt-tree;
        };
    };
}
