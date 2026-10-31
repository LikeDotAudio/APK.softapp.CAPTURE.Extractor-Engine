# Architecture — CAPTURE.Extractor-Engine

## Use
A Rust library crate (`extractor_engine`, `crate-type = ["rlib"]`). Add it **by commit**, the
way plugins pin a sibling (`.apk.scripts/plugin_standalone.py`: "a sibling … from that sibling's
own repository by `rev`"), so a clone of the consumer builds against a known engine:

```toml
extractor_engine = { git = "https://github.com/LikeDotAudio/APK.softapp.CAPTURE.Extractor-Engine", rev = "<full sha>" }
```

Inside the monorepo the consumer's locally excluded `.cargo/config.toml` patches that URL back to
this folder, so edits here compile into the consumer without a push:

```toml
[patch."https://github.com/LikeDotAudio/APK.softapp.CAPTURE.Extractor-Engine"]
extractor_engine = { path = "<relative path to this folder>" }
```

Every consumer pins the SAME rev: `wasm_extractor` links this crate and the analyzer, and two revs
would be two `extractor_engine` packages with two `Region` types.

Decode audio yourself to mono `f32` + sample rate, then:

```rust
let regions = extractor_engine::detect_regions_from_samples(&pcm, sr, &DetectParams::default());
let cut = extractor_engine::slice_region(&pcm, sr, &regions[0], FadeCurve::EqualPower);
let wav = extractor_engine::encode_wav_pcm16(&cut, sr);
```

## API (`src/lib.rs`)
| Item | Line | Purpose |
|---|---:|---|
| `PeakRegion` | 27 | **The** `.PEAK` region schema (index, start/end/duration seconds, peak amplitude, name; all `serde(default)`). The analyzer's `Core/peak.rs::Region` flattens it and adds `analysis`. |
| `Region` | 43 | The Extractor's chunk: a flattened `PeakRegion` (`span`, and `Deref` to it) plus `serde(default)` fades. |
| `FadeCurve` | 74 | `Linear` or `EqualPower`. |
| `DetectParams` / `Default` / `legacy()` | 90 / 137 / 165 | Extractor UI gate (open −40 dB, close −46 dB, 0.15 s min silence, 0.05 s min region, 10/30 ms pad, onset refinement, zero-cross snap, 9 dB lift) vs. the analyzer's single-threshold path. |
| `amplitude_envelope` | 183 | RMS envelope at ~200 fps (hop = sr/200). |
| `detect_regions_with_params` | 265 | Regions from a precomputed envelope (analyzer parity). |
| `detect_regions_from_samples` | 376 | Regions from PCM with onset refinement, padding, zero-cross snap (Extractor path). |
| `snap_to_zero_crossing`, `refine_onset` | 452, 482 | Cut-point refinement. |
| `apply_fades`, `slice_samples`, `slice_region` | 526, 546, 567 | Cut and fade. |
| `encode_wav_pcm16` | 577 | 44-byte-header 16-bit PCM WAV. |

## Who links it
- `SCANALYZER.Like.audio/Web_Front/wasm_extractor` — WASM wrapper, run in a Web Worker by the Extractor tab.
- `SCANALYZER.Like.audio/Web_Front/src-tauri` — the Tauri desktop build.
- `PROCESSOR/PROCESSOR.SampleAnalyzer` — the sample analyzer.

Inside APK.audio, cargo writes to the root's shared `target/` (root `.cargo/config.toml`); a standalone clone writes `target/` here, which `.gitignore` ignores.

## Build script and `links`
`build.rs` prints `cargo:src_dir=<this crate>/src`; with `links = "extractor_engine"` cargo hands
that to every direct dependent's build script as `DEP_EXTRACTOR_ENGINE_SRC_DIR`. The analyzer
hashes that directory into `ANALYZER_VERSION`, wherever cargo resolved the crate (git checkout or
local patch) — it no longer guesses the sibling folder.

## Check
`./check.sh` — `cargo test` (12 tests, including the `.PEAK` region round trip) and
`cargo build --target wasm32-unknown-unknown`.
