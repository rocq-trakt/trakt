{ lib }:

with lib;
{
  mkTraktName =
    {
      rocq-core,
      stdlib,
      rocq-elpi,
      trakt,
      ...
    }:
    "${mkFmt rocq-core.version}-${mkFmt stdlib.version}-${mkFmt rocq-elpi.version}-${mkFmt trakt.version}";

  mkTraktScope =
    pkgs:
    {
      rocq,
      stdlib,
      rocq-elpi,
      trakt ? "dev",
      ...
    }:
    (mkRocqPackages pkgs rocq).overrideScope (
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

  mkTrakt =
    pkgs: versions:
    let
      rocqPackages = mkTraktScope pkgs versions;
    in
    {
      name = "trakt-${mkTraktName rocqPackages}";
      value = rocqPackages.trakt;
    };
}
