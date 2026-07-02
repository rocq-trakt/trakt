{ lib }:

with lib;
{
  mkTrakt =
    pkgs:
    {
      rocq,
      stdlib,
      rocq-elpi,
      elpi ? null,
      trakt ? "dev",
    }@attrs:
    let
      rocqPackages = (mkRocqPackages pkgs rocq).overrideScope (
        _: prev:
        {
          stdlib = prev.stdlib.override { version = stdlib; };
          rocq-elpi = prev.rocq-elpi.override { version = rocq-elpi; };
          trakt = prev.trakt.override { version = trakt; };
        }
        // pkgs.lib.optionalAttrs (prev.rocq-core.version == "dev") {
          zify = null;
        }
      );
    in
    {
      name = "trakt-${mkFmt rocq}-${mkFmt stdlib}-${mkFmt rocq-elpi}-${mkFmt trakt}";
      value = rocqPackages.trakt;
    };
}
