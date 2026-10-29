{
  # Libraries
  lib,
  mkRocqDerivation,

  # Dependencies
  hierarchy-builder,
  mathcomp,
  micromega-plugin,
  rocq-core,
  rocq-elpi,
  stdlib,
}:

let
  micromega-plugin' = lib.overrideRocqDerivation rec {
    version = "1.1.1";
    release.${version}.hash = "sha256-TIUbrMRoPkLx3QcBGTAEdnzqt4HcKOHaQwJWUtBXUQA";
  } micromega-plugin;

  pinned = {
    hierarchy-builder = hierarchy-builder.override {
      version = "1.10.3";
    };

    micromega-plugin = micromega-plugin'.override {
      version = "1.1.0";
    };

    mathcomp = mathcomp.override {
      inherit (pinned) hierarchy-builder micromega-plugin;
      version = "2.6.0";
    };
  };
in

mkRocqDerivation rec {
  owner = "math-comp";
  repo = "mczify";

  pname = "zify";

  propagatedBuildInputs = [
    pinned.mathcomp
    stdlib
  ];

  preBuild = ''
    sed -i -e 's/coq_makefile/rocq makefile/g' Makefile
  '';

  version = "f11611e6f17c9152b05ad67aba26cc5c35b14fa0";
  release.${version}.sha256 = "sha256-PU72hc5iym3BeYFXgzuQ7OBmYWIxr+2MAiOHsAAcEhc=";
}
