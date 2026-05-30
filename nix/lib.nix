final: _: {
  mkTrakt =
    let
      isVersion = str: builtins.match "[0-9]+(\\.[0-9]+)*" str != null;
      mkFmt = str: final.removePrefix "v" (final.replaceStrings [ "." ] [ "_" ] str);

      mkRocqPackages =
        pkgs: version:
        if isVersion version then
          pkgs."rocqPackages_${mkFmt version}"
        else
          pkgs.rocqPackages.overrideScope (
            _: prev: {
              rocq-core = prev.rocq-core.override { inherit version; };
            }
          );

      mkStdlib = rocqPackages: version: rocqPackages.stdlib.override { inherit version; };

      mkRocqElpi =
        rocqPackages: version: elpi-version:
        rocqPackages.rocq-elpi.override { inherit elpi-version version; };
    in
    pkgs:
    {
      rocq,
      stdlib,
      elpi,
      rocq-elpi ? null,
    }:
    let
      rocqPackages = mkRocqPackages pkgs rocq;
    in
    {
      name = "trakt-${mkFmt rocq}-${mkFmt stdlib}-${mkFmt rocq-elpi}";
      value = rocqPackages.trakt.override {
        stdlib = mkStdlib rocqPackages stdlib;
        rocq-elpi = mkRocqElpi rocqPackages rocq-elpi elpi;
      };
    };

  availableVersions =
    let
      stdlib_9_1_or_above = [ "9.1" ];
      stdlib_9_0_or_above = [ "9.0" ] ++ stdlib_9_1_or_above;
    in
    rec {
      rocq_9_0_or_below = final.cartesianProduct {
        rocq = [ "9.0" ];
        stdlib = stdlib_9_0_or_above;
      };

      rocq_9_1_or_below =
        rocq_9_0_or_below
        ++ final.cartesianProduct {
          rocq = [ "9.1" ];
          stdlib = stdlib_9_0_or_above;
        };

      rocq_9_2_or_below =
        rocq_9_1_or_below
        ++ final.cartesianProduct {
          rocq = [ "9.2" ];
          stdlib = stdlib_9_1_or_above;
        };
    };

  mkTraktDep =
    let
      update = x: y: x // y;
    in
    rocq-elpi: elpi: rocqs:
    map (update {
      inherit rocq-elpi elpi;
    }) rocqs;
}
