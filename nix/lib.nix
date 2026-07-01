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
      defaultElpiVersion =
        with rocqPackages.lib;
        let
          case = case: out: { inherit case out; };
        in
        version:
        switch version [
          (case (versions.isGe "v3.4.0") "v3.7.1")
          (case (versions.isGe "v3.3.1") "v3.6.2")
          (case (versions.isGe "v3.2.0") "v3.5.0")
        ] null;

      rocqPackages = (mkRocqPackages pkgs rocq).overrideScope (
        final: prev:
        {
          stdlib = prev.stdlib.override { version = stdlib; };
          rocq-elpi = prev.rocq-elpi.override {
            version = rocq-elpi;
            elpi-version = defaultElpiVersion rocq-elpi;
          };
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
