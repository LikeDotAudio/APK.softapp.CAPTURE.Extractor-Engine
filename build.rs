//! Tells a dependent where this crate's source is, so `oa_sample_analyzer`'s build
//! script can hash it into ANALYZER_VERSION (region cutting shapes the stored
//! `.PEAK` regions, so a change here must re-analyze old records).
//!
//! `links = "extractor_engine"` in Cargo.toml turns `cargo:src_dir=` below into the
//! env var `DEP_EXTRACTOR_ENGINE_SRC_DIR` in every DIRECT dependent's build script —
//! the path cargo actually resolved (a git checkout, or a local `[patch]` path),
//! instead of the dependent guessing a sibling folder `../../CAPTURE/...`.
fn main() {
    let dir = std::env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR");
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:src_dir={dir}/src");
}
