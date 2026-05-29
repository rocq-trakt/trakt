{
  # Libraries
  lib,
  mkRocqDerivation,

  # Dependencies
  mathcomp,
  stdlib,
}:

mkRocqDerivation rec {
  owner = "math-comp";
  repo = "mczify";

  pname = "zify";
  propagatedBuildInputs = [
    mathcomp
    stdlib
  ];

  preBuild = ''
    sed -i -e 's/coq_makefile/rocq makefile/g' Makefile
  '';

  version = "f11611e6f17c9152b05ad67aba26cc5c35b14fa0";
  release.${version}.sha256 = "sha256-PU72hc5iym3BeYFXgzuQ7OBmYWIxr+2MAiOHsAAcEhc=";
}
