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

                propagatedBuildInputs = [
                  stdlib
                  rocq-elpi
                ];

                meta = {
                  description = "A generic goal preprocessing tool for proof automation tactics in Rocq";
                  homepage = "https://github.com/rocq-trakt/trakt";
                  license = pkgs.lib.licenses.lgpl3;
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
        { pkgs, system, ... }:
        rec {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };

          packages.default = pkgs.rocqPackages.trakt;

          checks = {
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
