final: _: {
  mkTrakt =
    let
      isVersion = str: builtins.match "[0-9]+(\\.[0-9]+)*" str != null;

      mkFmt = final.replaceStrings [ "." ] [ "_" ];

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
      stdlib ? null,
      elpi ? null,
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
}
