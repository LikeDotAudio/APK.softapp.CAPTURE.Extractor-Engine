# Smoke test — CAPTURE.Extractor-Engine

Is `CAPTURE.Extractor-Engine` deployed? Written by `.apk.scripts/smoke.py` from the module's own shape; what each check means is in that script's header.

← [Wiki home](../README.md)

**✅ PASS** — 3/3 checks, since 2026-11-12 00:15 EST

| Check | Target | Result | Detail |
|---|---|---|---|
| pushed | [APK.softapp.CAPTURE.Extractor-Engine](https://github.com/LikeDotAudio/APK.softapp.CAPTURE.Extractor-Engine.git) | ✅ | HEAD is on origin |
| web | [Cargo.toml](https://apk.audio/APK%3ASoftapps/CAPTURE/CAPTURE.Extractor-Engine/Cargo.toml) | ✅ | HTTP 200 |
| app | `OS/Capture Extractor Engine` → `PODS/POD.THIN/Softapps/SCANALYZER_SUITE/SCANALYZER.Like.audio/Web_Front/dist/index.html` | ✅ | present |

Re-run: `python3 .apk.scripts/smoke.py PODS/POD.THIN/Softapps/CAPTURE/CAPTURE.Extractor-Engine`

<!-- smoke:sig a33bd3e7c1ec since 2026-11-12 00:15 EST -->
