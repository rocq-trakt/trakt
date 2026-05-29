{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
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
        lib = nixpkgs.lib.extend (import ./nix/lib.nix);
        overlays.default = import ./nix/overlay;
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
            self.lib.listToAttrs (map (self.lib.mkTrakt pkgs) combinaison);

          formatter = pkgs.nixfmt-tree;
        };
    };
}
