{
  # Librairies
  lib,

  # Previous overlay
  rocq-core,
  rocq-elpi,

  # Arguments
  version ? null,
}:

with lib;
with lib.versions;
let
  case = case: out: { inherit case out; };
in
overrideRocqDerivation (rec {
  inherit version;

  pname = "rocq-elpi";

  defaultVersion = switch rocq-core.rocq-version [
    (case (range "9.0" "9.2") "3.4.0")
    (case (range "9.0" "9.2") "3.3.1")
    (case (range "9.0" "9.1") "3.2.0")
  ] version;

  propagatedBuildInputs =
    let
      rocq-elpi-version = if version == null then defaultVersion else version;
      elpi-version = switch rocq-elpi-version [
        (case (versions.isEq "3.4.0") "3.7.1")
        (case (versions.isEq "3.3.1") "3.6.2")
        (case (versions.isEq "3.2.0") "3.4.5")
      ] "3.7.1";
    in
    [
      rocq-core.ocamlPackages.findlib
      rocq-core.ocamlPackages.ppx_optcomp
      (rocq-core.ocamlPackages.elpi.override { version = elpi-version; })
    ];

  release = {
    "3.4.0".sha256 = "sha256-8x2Sa/+pUpXEqB+NdyfOyw6Yyzp6Q1k5LnhrjG/qJNM=";
    "3.3.1".sha256 = "sha256-/ehf2g/+riXOmfXs90Mx0PnKA0wJyombHK+rbVePjw0=";
    "3.2.0".sha256 = "sha256-FyYG/8lEyt1L/paMez8jYAnnUE+sxIp4Da5MztmwJ/c=";
  };
}) rocq-elpi
