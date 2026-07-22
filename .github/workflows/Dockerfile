# This image comes from rocq-community/docker-base
# NOTE: This is no longer required once the base image will use dune 3.21.1

FROM debian:12-slim

ARG OPAM_VERSION=2.3.0
ENV OPAM_VERSION=${OPAM_VERSION}

SHELL ["/bin/bash", "--login", "-o", "pipefail", "-c"]

# hadolint ignore=DL3008
RUN cat /proc/cpuinfo /proc/meminfo \
  && [ -n "${OPAM_VERSION}" ] \
  && apt-get update -y -q \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y -q --no-install-recommends \
    autoconf \
    automake \
    bubblewrap \
    build-essential \
    ca-certificates \
    curl \
    git \
    # gnupg is temporarily installed and will not be kept in the image
    gnupg \
    less \
    libgmp-dev \
    m4 \
    openssh-client \
    pkg-config \
    rlwrap \
    rsync \
    sudo \
    time \
    unzip \
  && binary="opam-${OPAM_VERSION}-$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')" \
  && set -x \
  && curl -fSL -o "/tmp/${binary}" "https://github.com/ocaml/opam/releases/download/${OPAM_VERSION}/${binary}" \
  && curl -fSL -o "/tmp/${binary}.sig" "https://github.com/ocaml/opam/releases/download/${OPAM_VERSION}/${binary}.sig" \
  && curl -fsSL https://opam.ocaml.org/opam-dev-pubkey.pgp | gpg --batch --import \
  && gpg --batch --verify "/tmp/${binary}.sig" "/tmp/${binary}" \
  && mv "/tmp/${binary}" /usr/local/bin/opam \
  && chmod a+x /usr/local/bin/opam \
  && rm -f "/tmp/${binary}.sig" \
  && rm -fr /root/.gnupg \
  && DEBIAN_FRONTEND=noninteractive apt-get purge -y -q --auto-remove gnupg \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Use Docker build args to set the UID/GID
ARG guest_uid=1000
ARG guest_gid=${guest_uid}

# Add rocq group and user with sudo perms
# hadolint ignore=SC2174
RUN groupadd -g ${guest_gid} rocq \
  && useradd --no-log-init -m -s /bin/bash -g rocq -G sudo -p '' -u ${guest_uid} rocq \
  # Create dirs for user scripts
  && mkdir -m 775 -p -v /home/rocq/bin /home/rocq/.local/bin \
  && chown rocq:rocq /home/rocq/bin /home/rocq/.local /home/rocq/.local/bin

# Load travis.sh, umask.sh at login
ADD \
    https://raw.githubusercontent.com/rocq-community/docker-base/refs/heads/master/base/travis.sh \
    https://github.com/rocq-community/docker-base/blob/master/base/umask.sh \
    /etc/profile.d/

WORKDIR /home/rocq

USER rocq

ENV NJOBS="2"
ENV OPAMPRECISETRACKING="1"
ARG COMPILER=4.14.2+flambda
ENV COMPILER=${COMPILER}
# The following variable is unneeded for ocaml < 4.12
# Otherwise, use e.g.:
# --build-arg=COMPILER=4.12.0+flambda
# --build-arg=COMPILER_PACKAGE=ocaml-variants.4.12.0+options,ocaml-option-flambda
ARG COMPILER_PACKAGE=ocaml-variants.4.14.2+options,ocaml-option-flambda
ARG OCAMLFIND_VERSION=1.9.6
ENV OCAMLFIND_VERSION=${OCAMLFIND_VERSION}
ARG DUNE_VERSION=3.21.1
ENV DUNE_VERSION=${DUNE_VERSION}

ARG NUM_VERSION=1.5-1
# or 1.4

ARG ZARITH_VERSION=1.14
ENV ZARITH_VERSION=${ZARITH_VERSION}

# hadolint ignore=SC2046
RUN set -x \
  && opam init --auto-setup --yes --bare --disable-sandboxing \
  && opam switch create --jobs=${NJOBS} ${COMPILER} ${COMPILER_PACKAGE:+--package=}${COMPILER_PACKAGE} \
  && eval $(opam env) \
  && opam repository add --all-switches --set-default rocq-released https://coq.inria.fr/opam/released \
  && opam update -y \
  && opam install -y -j 1 opam-depext \
  && opam pin add -n -k version ocamlfind ${OCAMLFIND_VERSION} \
  && opam pin add -n -k version dune ${DUNE_VERSION} \
  && opam pin add -n -k version num ${NUM_VERSION} \
  && opam pin add -n -k version zarith ${ZARITH_VERSION} \
  && opam install -y -v -j ${NJOBS} ocamlfind dune num zarith \
  && opam clean -a -c -s --logs \
  && chmod -R g=u /home/rocq/.opam \
  && opam config list && opam list

ENTRYPOINT ["opam", "exec", "--"]

CMD ["/bin/bash", "--login"]
