{
  # Libraries
  lib,
  mkRocqDerivation,

  # Dependencies
  hierarchy-builder,
  micromega-plugin,
}:

let
  mkMathcompDrv =
    name: propagatedBuildInputs:
    mkRocqDerivation rec {
      inherit propagatedBuildInputs;

      owner = "math-comp";
      repo = "math-comp";

      pname = "mathcomp-${name}";
      preBuild = "cd ${name}";

      version = "30d8712ff09866d336e3153a6109db2d0f50e7d8";
      release.${version}.sha256 = "sha256-20PQsU1Z+T6cw6Oa3XnnYutf8z9NPGvl4hnk+bOWDo4=";
    };

  boot = mkMathcompDrv "boot" [ hierarchy-builder ];
  order = mkMathcompDrv "order" [ boot ];
  finite-group = mkMathcompDrv "finite_group" [ boot ];
  algebra = mkMathcompDrv "algebra" [
    finite-group
    micromega-plugin
    order
  ];
in
algebra
