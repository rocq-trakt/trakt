{
  # Libraries
  lib,
  mkRocqDerivation,

  # Dependencies
  git,
  rocq-elpi,
  stdlib,
  zify ? null,
}:

let
  opam-name = "rocq-trakt";
in
mkRocqDerivation {
  inherit opam-name;
  pname = "trakt";

  src = ../..;
  version = "dev";
  useDune = true;

  nativeBuildInputs = [
    git
  ];

  propagatedBuildInputs = [
    rocq-elpi
    stdlib
  ];

  doCheck = true;

  checkInputs = [ zify ];
  checkPhase =
    lib.optionalString (isNull zify) ''
      rm -rf example
    ''
    + ''
      runHook preCheck
      dune runtest -p ${opam-name} ''${enableParallelBuilding:+-j $NIX_BUILD_CORES}
      runHook postCheck
    '';

  meta = {
    description = "A generic goal preprocessing tool for proof automation tactics in Rocq";
    homepage = "https://github.com/rocq-trakt/trakt";
    license = lib.licenses.lgpl3Plus;
  };
}
