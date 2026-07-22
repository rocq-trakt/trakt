#!/usr/bin/env bash

set -ex

git clone https://github.com/rocq-community/docker-base.git
git clone https://github.com/rocq-community/docker-rocq.git

# Patch FROM to accept a custom image
sed -i -e 's|^FROM .*|FROM ghcr.io/rocq-trakt/base:latest|' \
    docker-rocq/rocq/stable/Dockerfile

docker build --format docker \
    -t ghcr.io/rocq-trakt/base:latest \
    --build-arg OPAM_VERSION=2.3.0 \
    --build-arg COMPILER=4.14.2+flambda \
    --build-arg COMPILER_PACKAGE=ocaml-variants.4.14.2+options,ocaml-option-flambda \
    --build-arg OCAMLFIND_VERSION=1.9.6 \
    --build-arg DUNE_VERSION=3.21.1 \
    --build-arg NUM_VERSION=1.5-1 \
    --build-arg ZARITH_VERSION=1.14 \
    docker-base/base -f rocq-single/Dockerfile

docker build --format docker \
    -t ghcr.io/rocq-trakt/rocq:latest \
    --build-arg ROCQ_EXTRA_OPAM=rocq-elpi \
    --build-arg ROCQ_VERSION=9.2.0 \
    --build-arg ROCQ_STDLIB_VERSION=9.1.0 \
    --build-arg BUILD_DATE=1970-00-00T00:00:00Z \
    --build-arg VCS_REF=V9.2.0 \
    docker-rocq/rocq/stable

rm -rf docker-base docker-rocq
