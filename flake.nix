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
        overlays.default = import ./nix/trakt;
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
            trakt = pkgs.rocqPackages_9_0.trakt;
          };

          checks =
            let
              combinaison =
                let
                  rocq_9_0 = [
                    {
                      rocq = "9.0";
                      stdlib = "9.0";
                    }
                    {
                      rocq = "9.0";
                      stdlib = "9.1";
                    }
                  ];

                  rocq_9_1 = rocq_9_0 ++ [
                    {
                      rocq = "9.1";
                      stdlib = "9.0";
                    }
                    {
                      rocq = "9.1";
                      stdlib = "9.1";
                    }
                  ];

                  rocq_9_2 = rocq_9_1 ++ [
                    {
                      rocq = "9.2";
                      stdlib = "9.1";
                    }
                  ];
                in
                (map (
                  x:
                  x
                  // {
                    rocq-elpi = "2.5.2";
                    elpi = "v2.0.7";
                  }
                ) rocq_9_0)
                ++

                  (map (
                    x:
                    x
                    // {
                      rocq-elpi = "2.6.0";
                      elpi = "v2.0.7";
                    }
                  ) rocq_9_1)
                ++

                  (map (
                    x:
                    x
                    // {
                      rocq-elpi = "3.0.0";
                      elpi = "v3.0.1";
                    }
                  ) rocq_9_1)
                ++

                  (map (
                    x:
                    x
                    // {
                      rocq-elpi = "3.1.0";
                      elpi = "v3.2.0";
                    }
                  ) rocq_9_1)
                ++

                  (map (
                    x:
                    x
                    // {
                      rocq-elpi = "3.2.0";
                      elpi = "v3.5.0";
                    }
                  ) rocq_9_1)
                ++

                  (map (
                    x:
                    x
                    // {
                      rocq-elpi = "v3.3.1";
                      elpi = "v3.6.2";
                    }
                  ) rocq_9_2)
                ++

                  (map (
                    x:
                    x
                    // {
                      rocq-elpi = "v3.4.0";
                      elpi = "v3.7.1";
                    }
                  ) rocq_9_2);
            in
            self.lib.listToAttrs (map (self.lib.mkTrakt pkgs) combinaison);

          formatter = pkgs.nixfmt-tree;
        };
    };
}
