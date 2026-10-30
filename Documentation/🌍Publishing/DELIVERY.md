# Delivery — CAPTURE.Extractor-Engine

## Build and test
`cargo test` (11 unit tests in `src/lib.rs`) and `cargo build --release`. No CI in this repo. `.apk.scripts/smoke.py` (root) checks HEAD is on origin — see [SMOKE.md](../%F0%9F%A7%A9Manual%20and%20Artifacts/SMOKE.md).

## Where it lands
A library is never shipped on its own; it lands inside what links it:
- **apk.audio** — the APK.audio root's `.github/workflows/ci.yml`, on a push to the root's `main`, runs `wasm-pack build wasm_extractor --target web --release` in Scanalyzer's `Web_Front` (compiling this crate to WASM), builds the bundle and uploads it with `PODS/POD.THIN/WEB.Frontend-Assets/.apk.scripts/deploy.py`. Live: `https://apk.audio/APK:Softapps/SCANALYZER_SUITE/SCANALYZER.Like.audio/Web_Front/dist/index.html?solo=1#/extractor`.
- **Desktop** — the Scanalyzer Tauri build (`Web_Front/src-tauri`), built by hand.
- **Sample analyzer** — `PROCESSOR.SampleAnalyzer`, by that repo's build.
- The source tree is also copied into node images with the Softapps tree (`.rs` and `Cargo.*` are kept, since NODE.BareMetal builds from the same context).

## Not automated
`cargo test` runs in no workflow; a change here reaches apk.audio only after the root's submodule bump and CI run.

Repository: `https://github.com/LikeDotAudio/APK.softapp.CAPTURE.Extractor-Engine`
