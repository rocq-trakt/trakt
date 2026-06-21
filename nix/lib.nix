final: _: {
  mkFmt = str: final.removePrefix "v" (final.replaceStrings [ "." ] [ "_" ] str);

  mkRocqCoreScope =
    { pkgs, rocq-core, ... }:
    let
      subset = "rocqPackages_${final.mkFmt rocq-core}";
    in
    if builtins.hasAttr subset pkgs then
      pkgs.${subset}
    else
      pkgs.rocqPackages.overrideScope (
        _: prev: {
          rocq-core = prev.rocq-core.override { version = rocq-core; };
          zify = null;
        }
      );

  mkRocqStdlibScope =
    { rocq-stdlib, ... }@args:
    (final.mkRocqCoreScope args).overrideScope (
      _: prev: {
        stdlib = prev.stdlib.override { version = rocq-stdlib; };
      }
    );

  mkRocqElpiScope =
    {
      rocq-elpi,
      elpi ? null,
      ...
    }@args:
    (final.mkRocqStdlibScope args).overrideScope (
      _: prev: {
        rocq-elpi = prev.rocq-elpi.override {
          version = rocq-elpi;
          elpi-version = elpi;
        };
      }
    );

  mkTraktScope =
    {
      rocq-trakt ? "dev",
      ...
    }@args:
    (final.mkRocqElpiScope args).overrideScope (
      _: prev: {
        trakt = prev.trakt.override {
          version = rocq-trakt;
        };
      }
    );

  mkTrakt =
    pkgs: args: with final.mkRocqElpiScope ({ inherit pkgs; } // args); {
      name = "trakt-${final.mkFmt rocq-core.version}-${final.mkFmt stdlib.version}-${final.mkFmt rocq-elpi.version}";
      value = trakt;
    };

  compatibilityRocqMatrix =
    let
      stdlib_9_1_or_above = [ "9.1" ];
      stdlib_9_0_or_above = [ "9.0" ] ++ stdlib_9_1_or_above;
    in
    rec {
      rocq_9_1_or_below = final.cartesianProduct {
        rocq-core = [
          "9.0"
          "9.1"
        ];
        rocq-stdlib = stdlib_9_0_or_above;
      };

      rocq_9_2_or_below =
        rocq_9_1_or_below
        ++ final.cartesianProduct {
          rocq-core = [ "9.2" ];
          rocq-stdlib = stdlib_9_1_or_above;
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
