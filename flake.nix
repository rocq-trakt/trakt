{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";

    rocq-utils = {
      url = "git+https://codeberg.org/lafeychine/rocq-utils";
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
          };

          checks = pkgs.lib.listToAttrs (
            map (self.lib.mkTrakt pkgs) (self.lib.mkRocqConstraints pkgs.rocqPackages "trakt")
          );
        };
    };
}
