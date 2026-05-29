let
  mkRocqPackages =
    base:
    base.overrideScope (
      final: _: {
        mathcomp = final.callPackage ./mathcomp.nix {
          hierarchy-builder = final.hierarchy-builder.override { version = "1.10.0"; };
        };
        zify = final.callPackage ./zify.nix { };

        trakt = final.callPackage ./trakt.nix { };
      }
    );
in

_: prev: {
  rocqPackages = mkRocqPackages (prev.rocqPackages or { });

  rocqPackages_9_0 = mkRocqPackages (prev.rocqPackages_9_0 or { });
  rocqPackages_9_1 = mkRocqPackages (prev.rocqPackages_9_1 or { });
  rocqPackages_9_2 = mkRocqPackages (prev.rocqPackages_9_2 or { });
}
