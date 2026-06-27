let
  mkRocqPackages =
    let
      case = case: out: { inherit case out; };
    in
    base:
    base.overrideScope (
      final: prev:
      with final.lib;
      with final.lib.versions;
      {
        zify = final.callPackage ./zify.nix { };
        trakt = final.callPackage ./trakt.nix { };

        # NOTE: If possible, upstream these matrices
        # It might not be accepted as overlapping is useless upstream
        stdlib = overrideRocqDerivation {
          defaultVersion = switch final.rocq-core.rocq-version [
            (case (range "9.0" "9.2") "9.1.0")
            (case (range "9.0" "9.1") "9.0.0")
          ] null;
        } prev.stdlib;

        rocq-elpi = overrideRocqDerivation {
          pname = "rocq-elpi";

          defaultVersion = switch final.rocq-core.rocq-version [
            (case (range "9.0" "9.2") "v3.4.0")
            (case (range "9.0" "9.2") "v3.3.1")
            (case (range "9.0" "9.1") "v3.2.0")
          ] null;
        } prev.rocq-elpi;
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
