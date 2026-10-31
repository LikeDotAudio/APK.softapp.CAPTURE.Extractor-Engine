#!/usr/bin/env bash
# Part of the APK.audio project — http://APK.audio — made by Anthony Kuzub
# MIT Licence. Free, for everyone, for ever. Full text in LICENSE at the root.
#
# The one check for this crate, run by hand before a push (the monorepo's CI
# deliberately verifies nothing; see the root .github/workflows header):
#   ./check.sh
# 1. the unit tests (gate, fades, zero-cross, WAV header, .PEAK round trip);
# 2. a build for wasm32-unknown-unknown — the browser's wasm_extractor links this
#    crate, so a std-only API sneaking in must fail here, not in the web build.
set -euo pipefail
cd "$(dirname "$0")"
cargo test --quiet
if rustup target list --installed 2>/dev/null | grep -qx wasm32-unknown-unknown; then
  cargo build --quiet --target wasm32-unknown-unknown
  echo "check.sh: tests + wasm32 build OK"
else
  echo "check.sh: tests OK; wasm32 SKIPPED (rustup target add wasm32-unknown-unknown)" >&2
fi
