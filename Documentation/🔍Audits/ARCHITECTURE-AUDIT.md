# 🔍 Architecture audit — CAPTURE.Extractor-Engine (2026-10-30)

Audited against the APK.audio multi-repo architecture standard: coupling, boundaries, duplication, contracts.
← [Audits](INDEX.md) · Improvements: [🛣Roadmap/IMPROVEMENTS.md](../%F0%9F%9B%A3Roadmap/IMPROVEMENTS.md)

## Bounded context
The one cutting DSP for the Extractor: region detection, onset refinement, zero-cross snap, fades, 16-bit WAV encode, over caller-supplied mono `f32` PCM. Rust library crate `extractor_engine` 0.1.0, one file `src/lib.rs` (731 lines), dependency `serde` only. Sampled: all tracked files; ran `cargo test` (11 passed); checked the three consumers' `Cargo.toml` and the analyzer's `Core/peak.rs`.

## Context map
| Talks to | How (topic / endpoint / file / import) | Relationship |
|---|---|---|
| SCANALYZER.Like.audio `Web_Front/wasm_extractor` | `extractor_engine = { git = …, rev = … }` (local `[patch]` to this folder) | Supplier — Shared Kernel |
| SCANALYZER.Like.audio `Web_Front/src-tauri` | same git rev | Supplier — Shared Kernel |
| PROCESSOR.SampleAnalyzer | same git rev; calls `DetectParams::legacy()` + `detect_regions_with_params`; reads `DEP_EXTRACTOR_ENGINE_SRC_DIR` (`links`) to hash this source | Supplier — Shared Kernel |
| `.PEAK` region schema | `PeakRegion` here is the one definition; the analyzer's `Region` flattens it | Supplier (Published Language) |
| WEB.OsApi launcher | [display.json](../../display.json) | Conformist |

## Scorecard
| Category | Score (0–3) | Finding |
|---|---|---|
| Coupling & Cohesion | 3 | A clean leaf (no I/O, `serde` only). Consumers pin it by git `rev`, patched to the local folder in the monorepo. |
| Boundary Integrity | 3 | Pure functions over slices; no vendor SDK, no app types; callers own decoding. |
| Duplication Control | 3 | Removed the TS/Rust mirror; `PeakRegion` is the one `.PEAK` region definition. |
| Testing & Contracts | 3 | 12 behaviour-named unit tests incl. a `.PEAK` region round trip; `./check.sh` adds the wasm32 build. |
| Change management | 2 | 0.2.0, consumers pinned by commit; no published tag yet (needs owner). `DetectParams::legacy()` is a deliberate compatibility shim. |
Score key: 3 meets the standard · 2 minor gaps · 1 significant gaps · 0 absent / violated.

## Findings
1. **Good — single source for cutting.** Web (WASM worker), desktop (Tauri) and the analyzer call the same functions; this replaced a hand-kept TS/Rust mirror ([README.md](../../README.md), `src/lib.rs` header).
2. **Good — a true leaf.** [Cargo.toml](../../Cargo.toml) depends on `serde` only; `crate-type = ["rlib"]`; no decoding or file I/O in `src/lib.rs`.
3. **Good — compatibility is explicit.** `DetectParams::legacy()` keeps stored `.PEAK` regions stable, and the noise-floor lift has a test proving it is a no-op on clean one-shots (`src/lib.rs`, `mod tests` from line 573).
4. **Needs owner: publish tag `v0.2.0`.** Consumers now pin a commit by `rev` (the house rule for siblings, `.apk.scripts/plugin_standalone.py`); a release tag would let them say `tag = "v0.2.0"`. Agents do not publish tags.

Delivered items (consumers by rev, `./check.sh`, one `PeakRegion`, dead topic dropped) are recorded in [🌍Publishing/DELIVERY.md](../%F0%9F%8C%8DPublishing/DELIVERY.md).
