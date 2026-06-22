{ nixpkgs }:

with nixpkgs.lib;
rec {
  mkFmt = str: removePrefix "v" (replaceStrings [ "." ] [ "_" ] str);

  mkCoreScope =
    { pkgs, rocq-core, ... }:
    let
      subset = "rocqPackages_${mkFmt rocq-core}";
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

  mkStdlibScope =
    { rocq-stdlib, ... }@args:
    (mkCoreScope args).overrideScope (
      _: prev: {
        stdlib = prev.stdlib.override { version = rocq-stdlib; };
      }
    );

  mkElpiScope =
    {
      rocq-elpi,
      elpi ? null,
      ...
    }@args:
    (mkStdlibScope args).overrideScope (
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
    (mkElpiScope args).overrideScope (
      _: prev: {
        trakt = prev.trakt.override {
          version = rocq-trakt;
        };
      }
    );

  mkTrakt =
    pkgs: args: with mkTraktScope ({ inherit pkgs; } // args); {
      name = "trakt-${mkFmt args.rocq-core}-${mkFmt args.rocq-stdlib}-${mkFmt args.rocq-elpi}";
      value = trakt;
    };

  compatibilityRocqMatrix =
    let
      stdlib_9_1_or_above = [ "9.1" ];
      stdlib_9_0_or_above = [ "9.0" ] ++ stdlib_9_1_or_above;
    in
    rec {
      rocq_9_1_or_below = cartesianProduct {
        rocq-core = [
          "9.0"
          "9.1"
        ];
        rocq-stdlib = stdlib_9_0_or_above;
      };

      rocq_9_2_or_below =
        rocq_9_1_or_below
        ++ cartesianProduct {
          rocq-core = [ "9.2" ];
          rocq-stdlib = stdlib_9_1_or_above;
        };
    };

  mkTraktDep =
    rocq-elpi: elpi: rocq-matrix:
    let
      versions = { inherit rocq-elpi elpi; };
    in
    map (rocq: rocq // versions) rocq-matrix;
}
