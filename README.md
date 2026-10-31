# CAPTURE.Extractor-Engine

> ⚡ **Extractor Engine** — the Rust crate `extractor_engine`: the one cutting DSP behind Scanalyzer's Extractor, in the browser (WASM) and on the desktop (native).

---

## 🧩 Architectural Role
* **Family**: CAPTURE (Scanalyzer)
* **Category**: Engine — Rust library crate (`display.json` `kind: rust`, subGroup `DSP Core`)
* **Pipeline Stage**: Scanalyzer produce step — region detection and slicing for the Extractor
* **Web Portal Entry**: none (a library; `display.json` has no `app`). Its UI is the Extractor tab, `SCANALYZER.Like.audio/Web_Front/dist/index.html?solo=1#/extractor`.
* **Remote Repository**: https://github.com/LikeDotAudio/APK.softapp.CAPTURE.Extractor-Engine

---

## ⚙️ What it is

`src/lib.rs` is pure DSP. It takes already-decoded **mono `f32` PCM + sample rate** and returns regions, sliced-and-faded audio and 16-bit WAV bytes. It decodes nothing, has no I/O and depends only on `serde`.

| Item | Purpose |
|---|---|
| `PeakRegion` | The `.PEAK` region schema — its one definition; the analyzer's `Core/peak.rs::Region` flattens it |
| `Region` | One detected chunk: a flattened `PeakRegion` plus the Extractor's `serde(default)` fade fields |
| `DetectParams` | Gate parameters. `Default` = the Extractor UI's algorithm (open −40 dB, close −46 dB hysteresis, 0.15 s min silence, 0.05 s min region, 10 ms attack / 30 ms release pad, transient-aware onset, zero-crossing snap, noise-floor lift 9 dB). `legacy()` = single threshold, no padding or refinement — the analyzer's path. |
| `amplitude_envelope` | RMS envelope at ~200 fps (hop = sr/200) |
| `detect_regions_with_params` | Regions from a precomputed envelope (analyzer parity path) |
| `detect_regions_from_samples` | Regions straight from PCM, with onset refinement, padding and zero-crossing snap (Extractor path) |
| `snap_to_zero_crossing`, `refine_onset` | Cut-point refinement (±~3 ms zero-cross search; steepest energy rise) |
| `apply_fades`, `slice_samples`, `slice_region` | Cut and fade, `FadeCurve::Linear` or `EqualPower` |
| `encode_wav_pcm16` | Canonical 44-byte-header 16-bit PCM WAV |

Region count is capped at 512 (`MAX_REGIONS`).

### Who links it (by `git = …, rev = …`, patched to this folder locally)
- `SCANALYZER.Like.audio/Web_Front/wasm_extractor/Cargo.toml` — the WASM wrapper run in a Web Worker
- `SCANALYZER.Like.audio/Web_Front/src-tauri/Cargo.toml` — the Tauri desktop build, in-process
- `PROCESSOR/PROCESSOR.SampleAnalyzer/Cargo.toml` — the sample analyzer

All three pin the same commit (see [ARCHITECTURE](Documentation/%F0%9F%A7%A9Manual%20and%20Artifacts/ARCHITECTURE.md#use)). `display.json` declares no topic: a library has no bus connection.

---

## 🚀 Build & test

```bash
./check.sh          # cargo test (12: gate, hysteresis, noise-floor lift, fades, zero-cross, WAV header, .PEAK round trip) + wasm32 build
cargo build --release
```

---

## 🧭 Philosophy
1. **One source of truth for cutting.** Web and desktop call these exact functions, so they cut identically — the crate replaced a hand-kept TypeScript/Rust mirror (`src/lib.rs` header; `wasm_extractor` description "so web and desktop cut identically").
2. **A leaf crate.** No decoding, no files, no app types; callers bring PCM, the crate returns numbers and bytes (`src/lib.rs` header, `Cargo.toml` — `serde` only).
3. **Old answers do not move silently.** `DetectParams::legacy()` keeps the analyzer's stored `.PEAK` regions stable; the one deliberate change (the noise-floor lift) is documented as a no-op on any cleanly-edited one-shot and is tested so (`legacy()`, test `the_lift_leaves_a_clean_one_shot_alone`).
4. **Measure the material, not just its peak.** The gate rises to 9 dB above the file's own 10 % noise floor, capped at −12 dB below peak, because a peak-only gate merged 43 breaths into one region (`noise_floor_margin_db`, `NOISE_FLOOR_QUANTILE`, `MAX_LIFTED_GATE_DB`).
5. **What you hear is what you export.** Fades apply the same gain the preview player uses, and cuts snap to zero crossings so exports do not click (`apply_fades`, `snap_to_zero_crossing`).
6. **Bounded on pathological input.** Empty input or a zero sample rate returns no regions; the region list is capped at 512 (`detect_regions_from_samples`, `MAX_REGIONS`).
7. **Each rule has a test named for the behaviour** (`mod tests` in `src/lib.rs`).

## 📚 Documentation
The wiki — principles, architecture, delivery — starts at [Documentation/README.md](Documentation/README.md).

<!-- wiki:smoke -->
**Smoke test** — ✅ PASS 1/1 since 2026-10-30 12:51 EDT — [results](Documentation/%F0%9F%A7%A9Manual%20and%20Artifacts/SMOKE.md)
<!-- /wiki:smoke -->
