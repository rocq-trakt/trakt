{
  # Libraries
  lib,
  mkRocqDerivation,

  # Dependencies
  git,
  rocq-elpi,
  stdlib,
  zify ? null,

  # Arguments
  version ? "dev",
}:

mkRocqDerivation rec {
  inherit version;

  owner = "rocq-trakt";
  pname = "trakt";

  defaultVersion = "dev";
  release."dev" = {
    src = lib.cleanSource ../..;
    hash = null;
  };

  opam-name = "rocq-trakt";
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
