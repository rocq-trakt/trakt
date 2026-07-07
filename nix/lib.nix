{ lib }:

with lib;
{
  mkTraktScope =
    pkgs:
    {
      rocq,
      stdlib,
      rocq-elpi,
      elpi ? null,
      trakt ? "dev",
      ...
    }:
    (mkRocqPackages pkgs rocq).overrideScope (
      _: prev:
      {
        stdlib = prev.stdlib.override { version = stdlib; };
        rocq-elpi = prev.rocq-elpi.override {
          version = rocq-elpi;
          elpi-version = elpi;
        };
        trakt = prev.trakt.override { version = trakt; };
      }
      // pkgs.lib.optionalAttrs (prev.rocq-core.version == "dev") {
        zify = null;
      }
    );

  mkTrakt =
    pkgs:
    versions@{
      rocq,
      stdlib,
      rocq-elpi,
      trakt ? "dev",
      ...
    }:
    {
      name = "trakt-${mkFmt rocq}-${mkFmt stdlib}-${mkFmt rocq-elpi}-${mkFmt trakt}";
      value = (mkTraktScope pkgs versions).trakt;
    };
}
