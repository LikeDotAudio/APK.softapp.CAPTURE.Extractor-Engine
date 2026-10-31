# Principles — CAPTURE.Extractor-Engine

The README's Philosophy, pointed at `src/lib.rs`. Ecosystem rules live in the APK.audio root's `Documentation/🏛Philosophy/`.

| Principle | Kept by |
|---|---|
| **One source of truth for cutting.** Web (WASM) and desktop (Tauri) and the sample analyzer call these exact functions, replacing a hand-kept TypeScript/Rust mirror. | `src/lib.rs:1–11` (crate doc); dependants' `Cargo.toml` `git = …, rev = …` entries (one rev for all) |
| **A leaf crate.** No decoding, no I/O, no app types; PCM in, numbers and bytes out. Only dependency: `serde`. | `Cargo.toml`, `src/lib.rs` |
| **Old answers do not move silently.** `DetectParams::legacy()` keeps the analyzer's stored `.PEAK` regions stable; the one deliberate change (noise-floor lift) is a no-op on a clean one-shot, and tested so. | `src/lib.rs:165` `legacy`, test `the_lift_leaves_a_clean_one_shot_alone` |
| **Measure the material, not just its peak.** The gate rises to 9 dB above the file's 10 % noise floor, capped 12 dB below peak. | `src/lib.rs:97` `NOISE_FLOOR_QUANTILE`, `:102` `MAX_LIFTED_GATE_DB`, `DetectParams::noise_floor_margin_db` |
| **What you hear is what you export.** Fades apply the preview player's gain; cuts snap to zero crossings so exports do not click. | `src/lib.rs:526` `apply_fades`, `:452` `snap_to_zero_crossing` |
| **Bounded on pathological input.** Empty input or a zero sample rate returns no regions; at most 512 regions. | `src/lib.rs:16` `MAX_REGIONS`, `:376` `detect_regions_from_samples` |
| **One schema for a `.PEAK` region.** `PeakRegion` is defined here once; the analyzer and the Extractor flatten it. | `src/lib.rs` `PeakRegion`, test `a_peak_record_region_round_trips` |
| **Each rule has a test named for the behaviour.** | `src/lib.rs` `mod tests` (12 tests), run by `./check.sh` |

## Where it falls short
- No release tag yet: consumers pin a commit. Publishing `v0.2.0` is the owner's (tags are not pushed by agents).
