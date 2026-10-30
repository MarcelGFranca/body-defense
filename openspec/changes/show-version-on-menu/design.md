## Decisions

- **One source for the name.** The Android export falls back to `application/config/version` when its `version/name` is empty; the installed APK reports `versionName` from it (checked with `dumpsys package`). Alternatives (a constant in code, or a second copy in the preset) would drift.
- **The code stays in the preset**, since it is a number the store compares and has no project setting.
