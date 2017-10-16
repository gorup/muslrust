#!/bin/bash
set -ex

docker_build() {
  local -r crate="$1"crate
  docker run --rm \
    -v "$PWD/test/${crate}:/volume" \
    -v cargo-cache:/root/.cargo \
    -e RUST_BACKTRACE=1 \
    -it clux/muslrust \
    cargo build -vv
  cd "test/${crate}"
  if [[ "$1" == "diesel" ]]; then
    # Diesel test crate is dynamic atm, and doesn't run
    ldd target/x86_64-unknown-linux-musl/debug/"${crate}" | grep libpq.so
  else
    ./target/x86_64-unknown-linux-musl/debug/"${crate}"
    [[ "$(ldd "target/x86_64-unknown-linux-musl/debug/${crate}")" =~ "not a dynamic" ]] && \
      echo "${crate} is a static executable"
  fi
}

# Helper to check how ekidd/rust-musl-builder does it
docker_build_ekidd() {
  local -r crate="$1"crate
  docker run --rm \
    -v "$PWD/test/${crate}:/home/rust/src" \
    -v cargo-cache:/home/rust/.cargo \
    -e RUST_BACKTRACE=1 \
    -it ekidd/rust-musl-builder:nightly \
    cargo build -vv
  cd "test/${crate}"
  ./target/x86_64-unknown-linux-musl/debug/"${crate}"
  [[ "$(ldd "target/x86_64-unknown-linux-musl/debug/${crate}")" =~ "not a dynamic" ]] && \
    echo "${crate} is a static executable"
}

# Helper to check how golddranks/rust_musl_docker does it
docker_build_golddranks() {
  local -r crate="$1"crate
  docker run --rm \
    -v "$PWD/test/${crate}:/workdir" \
    -v cargo-cache:/root/.cargo \
    -e RUST_BACKTRACE=1 \
    -it golddranks/rust_musl_docker:nightly-2017-10-03 \
    cargo build -vv
  cd "test/${crate}"
  ./target/x86_64-unknown-linux-musl/debug/"${crate}"
  [[ "$(ldd "target/x86_64-unknown-linux-musl/debug/${crate}")" =~ "not a dynamic" ]] && \
    echo "${crate} is a static executable"
}


docker_build "$1"
