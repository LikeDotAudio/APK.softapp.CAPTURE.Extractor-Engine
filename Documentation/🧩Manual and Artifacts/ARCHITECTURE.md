# Architecture — CAPTURE.Extractor-Engine

## Use
A Rust library crate (`extractor_engine`, `crate-type = ["rlib"]`). Add it by path:

```toml
extractor_engine = { path = "../../CAPTURE/CAPTURE.Extractor-Engine" }
```

Decode audio yourself to mono `f32` + sample rate, then:

```rust
let regions = extractor_engine::detect_regions_from_samples(&pcm, sr, &DetectParams::default());
let cut = extractor_engine::slice_region(&pcm, sr, &regions[0], FadeCurve::EqualPower);
let wav = extractor_engine::encode_wav_pcm16(&cut, sr);
```

## API (`src/lib.rs`)
| Item | Line | Purpose |
|---|---:|---|
| `Region` | 23 | One chunk; seconds / peak / name match the `.PEAK` schema; fade fields `serde(default)`. |
| `FadeCurve` | 41 | `Linear` or `EqualPower`. |
| `DetectParams` / `Default` / `legacy()` | 57 / 104 / 132 | Extractor UI gate (open −40 dB, close −46 dB, 0.15 s min silence, 0.05 s min region, 10/30 ms pad, onset refinement, zero-cross snap, 9 dB lift) vs. the analyzer's single-threshold path. |
| `amplitude_envelope` | 150 | RMS envelope at ~200 fps (hop = sr/200). |
| `detect_regions_with_params` | 232 | Regions from a precomputed envelope (analyzer parity). |
| `detect_regions_from_samples` | 345 | Regions from PCM with onset refinement, padding, zero-cross snap (Extractor path). |
| `snap_to_zero_crossing`, `refine_onset` | 423, 453 | Cut-point refinement. |
| `apply_fades`, `slice_samples`, `slice_region` | 497, 517, 538 | Cut and fade. |
| `encode_wav_pcm16` | 548 | 44-byte-header 16-bit PCM WAV. |

## Who links it
- `SCANALYZER.Like.audio/Web_Front/wasm_extractor` — WASM wrapper, run in a Web Worker by the Extractor tab.
- `SCANALYZER.Like.audio/Web_Front/src-tauri` — the Tauri desktop build.
- `PROCESSOR/PROCESSOR.SampleAnalyzer` — the sample analyzer.

Inside APK.audio, cargo writes to the root's shared `target/` (root `.cargo/config.toml`); a standalone clone writes `target/` here, which `.gitignore` ignores.
