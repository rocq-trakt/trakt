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
  version ? null,
}:

let
  case = case: out: { inherit case out; };
in mkRocqDerivation rec {
  inherit version;

  owner = "rocq-trakt";
  pname = "trakt";

  opam-name = "rocq-trakt";
  useDune = true;

  defaultVersion = lib.switch rocq-elpi.version [
    (case (lib.versions.isGe "3.2.0") "dev")
  ] null;

  release."dev" = {
    src = lib.cleanSource ../..;
    hash = null;
  };

  nativeBuildInputs = [
    git
  ];

  propagatedBuildInputs = [
    rocq-elpi
    stdlib
  ];

  doCheck = true;
  nativeCheckInputs = [ zify ];
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
