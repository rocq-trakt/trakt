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
      rocq-version,
      stdlib-version,
      elpi-version,
      rocq-elpi-version ? null,
    }:
    let
      rocqPackages = mkRocqPackages pkgs rocq-version;

      stdlib = mkStdlib rocqPackages stdlib-version;
      rocq-elpi = mkRocqElpi rocqPackages rocq-elpi-version elpi-version;
    in
    {
      name = "trakt-${mkFmt rocq-version}-${mkFmt stdlib-version}-${mkFmt rocq-elpi-version}";
      value = rocqPackages.trakt.override {
        inherit stdlib rocq-elpi;

        zify = rocqPackages.zify.override {
          inherit rocq-elpi;
        };
      };
    };

  availableVersions =
    let
      stdlib_9_1_or_above = [ "9.1" ];
      stdlib_9_0_or_above = [ "9.0" ] ++ stdlib_9_1_or_above;
    in
    rec {
      rocq_9_0_or_below = final.cartesianProduct {
        rocq-version = [ "9.0" ];
        stdlib-version = stdlib_9_0_or_above;
      };

      rocq_9_1_or_below =
        rocq_9_0_or_below
        ++ final.cartesianProduct {
          rocq-version = [ "9.1" ];
          stdlib-version = stdlib_9_0_or_above;
        };

      rocq_9_2_or_below =
        rocq_9_1_or_below
        ++ final.cartesianProduct {
          rocq-version = [ "9.2" ];
          stdlib-version = stdlib_9_1_or_above;
        };
    };

  mkTraktDep =
    let
      update = x: y: x // y;
    in
    rocq-elpi-version: elpi-version: rocqs:
    map (update {
      inherit rocq-elpi-version elpi-version;
    }) rocqs;
}
