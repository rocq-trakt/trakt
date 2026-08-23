let
  mkRocqPackages =
    base:
    base.overrideScope (
      final: prev: {
        rocq-elpi = final.callPackage ./rocq-elpi.nix { inherit (prev) rocq-elpi; };
        trakt = final.callPackage ./trakt.nix { };

        # NOTE: Remove these packages when they will be available upstream
        zify = final.callPackage ./zify.nix { };
      }
    );
in

final: prev: {
  rocqPackages = mkRocqPackages prev.rocqPackages;

  rocqPackages_9_0 = mkRocqPackages prev.rocqPackages_9_0;
  rocqPackages_9_1 = mkRocqPackages prev.rocqPackages_9_1;
  rocqPackages_9_2 = mkRocqPackages prev.rocqPackages_9_2;
}
