{
  # Libraries
  lib,
  mkRocqDerivation,

  # Dependencies
  rocq-elpi,
  stdlib,
}:

mkRocqDerivation rec {
  pname = "trakt";

  src = ../..;
  version = "dev";

  opam-name = "rocq-trakt";
  useDune = true;

  propagatedBuildInputs = [
    stdlib
    rocq-elpi
  ];

  doCheck = true;
  checkPhase = ''
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
