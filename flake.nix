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
        lib = import ./nix/lib.nix { inherit nixpkgs; };

        overlays = rec {
          trakt = import ./nix/pkgs;
          default = trakt;
        };
      };

      perSystem =
        {
          lib,
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

          checks =
            let
              combinaisons =
                with self.lib;
                with self.lib.compatibilityRocqMatrix;

                mkTraktDep "v3.2.0" "v3.5.0" rocq_9_1_or_below
                ++ mkTraktDep "v3.3.1" "v3.6.2" rocq_9_2_or_below
                ++ mkTraktDep "v3.4.0" "v3.7.1" rocq_9_2_or_below;
            in
            lib.listToAttrs (map (self.lib.mkTrakt pkgs) combinaisons);
        };
    };
}
