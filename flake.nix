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
        lib = nixpkgs.lib.fix (lib: nixpkgs.lib // import ./nix/lib.nix { inherit lib; });

        overlays = rec {
          trakt = import ./nix/pkgs;
          default = trakt;
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

          checks =
            let
              mkTrakt =
                { rocq-elpi, ... }@attrs:
                let
                  elpi =
                    if rocq-elpi == "v3.2.0" then
                      "v3.5.0"
                    else if rocq-elpi == "v3.3.1" then
                      "v3.6.2"
                    else
                      "v3.7.1";
                in
                self.lib.mkTrakt pkgs (attrs // { inherit elpi; });
            in
            self.lib.listToAttrs (map mkTrakt (self.lib.getMatrix pkgs.rocqPackages "trakt"));
        };
    };
}
