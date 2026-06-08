let
  mkRocqPackages =
    base:
    base.overrideScope (
      final: _: {
        zify = final.callPackage ./zify.nix { };
        trakt = final.callPackage ./trakt.nix { };
      }
    );
in

final: prev:
let
  # NOTE: Waiting the version 3.23 of Dune for Rocq 9.0 builds
  # See: https://github.com/ocaml/dune/pull/14093
  rocqPackages_9_0 = prev.rocqPackages_9_0.overrideScope (
    _: _: {
      dune = prev.ocamlPackages.dune_3.overrideAttrs rec {
        version = "3.23.0-alpha2";

        src = final.fetchurl {
          url = "https://github.com/ocaml/dune/releases/download/3.23.0_alpha2/dune-3.23.0.alpha2.tbz";
          hash = "sha256-gYLRz/nYqn+JAs1QOTRyq9lPSTHbzHNznLEqBGoYTZM=";
        };
      };
    }
  );
in
{
  rocqPackages = mkRocqPackages prev.rocqPackages;

  rocqPackages_9_0 = mkRocqPackages rocqPackages_9_0;
  rocqPackages_9_1 = mkRocqPackages prev.rocqPackages_9_1;
  rocqPackages_9_2 = mkRocqPackages prev.rocqPackages_9_2;
}
