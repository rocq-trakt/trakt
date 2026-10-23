{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";

    rocq-utils = {
      url = "github:lafeychine/rocq-utils";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      self,
      nixpkgs,
      rocq-utils,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      flake = {
        lib = nixpkgs.lib.fix (lib: rocq-utils.lib // import ./nix/lib.nix { inherit lib; });

        overlays = rec {
          trakt = import ./nix/pkgs;

          default = nixpkgs.lib.composeManyExtensions [
            rocq-utils.overlays.default
            self.overlays.trakt
          ];
        };
      };

      perSystem =
        {
          pkgs,
          system,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };

          formatter = pkgs.nixfmt-tree;

          packages = rec {
            inherit (pkgs.rocqPackages) trakt;

            default = trakt;

            # nix develop .#buggy.passthru.rocq-elpi --impure
            buggy = (self.lib.mkTrakt pkgs {
              rocq = "master";
              stdlib = "master";
              rocq-elpi = "master";
              trakt = "master";
            }).value;

            # nix develop .#buggy2 --impure
            buggy2 = (pkgs.rocqPackages.overrideScope (_: prev: {
              rocq-elpi = prev.rocq-elpi.override {
                version = "master";
              };
              rocq-core = prev.rocq-core.override {
                version = "master";
              };
            })).rocq-elpi;
          };

          checks = pkgs.lib.listToAttrs (
            map (self.lib.mkTrakt pkgs) (self.lib.mkRocqConstraints pkgs.rocqPackages "trakt")
          );
        };
    };
}
