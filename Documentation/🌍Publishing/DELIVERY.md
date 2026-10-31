# Delivery — CAPTURE.Extractor-Engine

## Build and test
`./check.sh` — `cargo test` (12 unit tests in `src/lib.rs`) and a `wasm32-unknown-unknown` build. Run by hand before a push; no workflow in this repo (the monorepo's CI verifies nothing on purpose). `.apk.scripts/smoke.py` (root) checks HEAD is on origin — see [SMOKE.md](../%F0%9F%A7%A9Manual%20and%20Artifacts/SMOKE.md).

## Where it lands
A library is never shipped on its own; it lands inside what links it:
- **apk.audio** — the APK.audio root's `.github/workflows/ci.yml`, on a push to the root's `main`, runs `wasm-pack build wasm_extractor --target web --release` in Scanalyzer's `Web_Front` (compiling this crate to WASM), builds the bundle and uploads it with `PODS/POD.THIN/WEB.Frontend-Assets/.apk.scripts/deploy.py`. Live: `https://apk.audio/APK:Softapps/SCANALYZER_SUITE/SCANALYZER.Like.audio/Web_Front/dist/index.html?solo=1#/extractor`.
- **Desktop** — the Scanalyzer Tauri build (`Web_Front/src-tauri`), built by hand.
- **Sample analyzer** — `PROCESSOR.SampleAnalyzer`, by that repo's build.
- Consumers pin this repository **by commit** (`rev`), not by `path`; see [ARCHITECTURE](../%F0%9F%A7%A9Manual%20and%20Artifacts/ARCHITECTURE.md#use).
- The source tree is also copied into node images with the Softapps tree (`.rs` and `Cargo.*` are kept, since NODE.BareMetal builds from the same context).

## Not automated
`./check.sh` runs in no workflow; a change here reaches apk.audio only after the root's submodule bump and CI run.

Repository: `https://github.com/LikeDotAudio/APK.softapp.CAPTURE.Extractor-Engine`

## Delivered from the 2026-10-30 audit
- **Consumers by commit, not by path** — the analyzer (`PROCESSOR.SampleAnalyzer/Cargo.toml`) and Scanalyzer (`Web_Front/src-tauri`, `wasm_extractor`) name this crate by `git = …, rev = …` with a locally excluded `.cargo/config.toml` `[patch]` back to this folder; the analyzer's build script finds this source through `links` (`DEP_EXTRACTOR_ENGINE_SRC_DIR`) instead of `../../CAPTURE/…`. Version bumped to 0.2.0 (the `Region` layout changed). Verified by `cargo test` here and in each consumer. Publishing a `v0.2.0` tag stays with the owner (see the audit).
- **One check command** — `./check.sh` runs `cargo test` and the `wasm32-unknown-unknown` build. Verified: passes.
- **One `.PEAK` region schema** — `PeakRegion` in `src/lib.rs` is the single definition; the Extractor's `Region` and the analyzer's `Core/peak.rs::Region` both flatten it (JSON unchanged). New test `a_peak_record_region_round_trips` parses a region as the analyzer writes it and as the Extractor UI sends it back. Verified: `cargo test` 12/12.
- **Dead topic dropped** — `display.json` no longer declares `APK.audio/Gui/Display/Extractor_Engine`; a library has no bus. The launcher tile is unchanged (WEB.OsApi derives a default topic for the snapshot).
