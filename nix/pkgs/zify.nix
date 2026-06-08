{
  # Libraries
  lib,
  mkRocqDerivation,

  # Dependencies
  hierarchy-builder,
  mathcomp,
  rocq-core,
  rocq-elpi,
  stdlib,
}:

let
  pinned = {
    # NOTE: A Rocq 9.2 compatible version is not available for 26.05
    mathcomp = lib.overrideRocqDerivation rec {
      version = "91d97df9cf3204b4dab84f4e24bc633e84b6473d";
      release.${version}.hash = "sha256-U91YDTfmT7a6tMoN0+FcGjUWg3iHLlWLWRj/DFdKjks=";
      releaseRev = lib.id;
    } mathcomp;
  };

  mathcomp' = pinned.mathcomp.override {
    hierarchy-builder = hierarchy-builder.override {
      version = "1.10.2";
    };
  };
in

mkRocqDerivation rec {
  owner = "math-comp";
  repo = "mczify";

  pname = "zify";

  propagatedBuildInputs = [
    mathcomp'
    stdlib
  ];

  preBuild = ''
    sed -i -e 's/coq_makefile/rocq makefile/g' Makefile
  '';

  version = "f11611e6f17c9152b05ad67aba26cc5c35b14fa0";
  release.${version}.sha256 = "sha256-PU72hc5iym3BeYFXgzuQ7OBmYWIxr+2MAiOHsAAcEhc=";
}
