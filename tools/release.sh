#!/bin/bash

set -e
set -u

check_installed() {
  if ! command -v "$1" > /dev/null; then
    echo "$1 must be installed and in your PATH!" >&2
    exit 1
  fi
}

downcase() {
  tr '[:upper:]' '[:lower:]'
}

sha256() {
  shasum -a 256 "$@" | awk '{ print "SHA256", "(" $2 ")", "=", $1 }'
}

verify_dependencies() {
  check_installed git
  check_installed bazel
  check_installed signify
}

run_tests() {
  bazel test //...
}

setup_release() {
  BAZEL_BIN=$(bazel info bazel-bin)
  RELEASE_DIR=$(mktemp -d)
}

build_release() {
  DISTRO="$1"

  RELEASE_TGZ="cryptdo-$DISTRO-$VERSION.tgz"
  RELEASE_SHA="$RELEASE_TGZ.sha256"
  RELEASE_SIG="$RELEASE_SHA.sig"
  COMMENT="untrusted comment: verify with cryptdo.pub"
  TOOLCHAIN="@io_bazel_rules_go//go/toolchain:${DISTRO}_amd64"

  bazel build --experimental_platforms="$TOOLCHAIN" //:cryptdo.tgz
  cp "$BAZEL_BIN/cryptdo.tgz" "$RELEASE_DIR/$RELEASE_TGZ"

  pushd "$RELEASE_DIR" >/dev/null
    sha256 "$RELEASE_TGZ" > "$RELEASE_SHA"
    signify -S -e -s "$SIGNIFY_SECKEY" -m "$RELEASE_SHA" -x "$RELEASE_SIG"
    sed -i '' "1s/.*/$COMMENT/" "$RELEASE_SIG"
    rm "$RELEASE_SHA"
    signify -C -p "$SIGNIFY_PUBKEY" -x "$RELEASE_SIG"
  popd >/dev/null

  git tag -a "$VERSION" -m "version $VERSION"
}

show_instructions() {
  echo "If everything looks good you need to:"
  echo
  echo "1. Push the tag ($VERSION)."
  echo "2. Upload the files in $RELEASE_DIR to"
  echo "   the associated release on GitHub."
  echo "3. Compile this on a different platform."
}

main() {
  verify_dependencies
  run_tests

  setup_release
  build_release linux
  build_release darwin

  show_instructions
}

VERSION=$1
SIGNIFY_PUBKEY=$2
SIGNIFY_SECKEY=$3

main

