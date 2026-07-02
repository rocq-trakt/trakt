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

final: prev: {
  rocqPackages = mkRocqPackages prev.rocqPackages;

  rocqPackages_9_0 = mkRocqPackages prev.rocqPackages_9_0;
  rocqPackages_9_1 = mkRocqPackages prev.rocqPackages_9_1;
  rocqPackages_9_2 = mkRocqPackages prev.rocqPackages_9_2;
}
