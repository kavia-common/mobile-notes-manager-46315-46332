#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
OUT_RESULT="$WORKSPACE/.validation_result"
EVIDENCE_FILE="$WORKSPACE/.last_build_artifact"
cd "$WORKSPACE"
# SKIP if no android dir
if [ ! -d "$WORKSPACE/android" ]; then echo -e "STATUS=SKIPPED\nREASON=no android project" > "$OUT_RESULT" && exit 0; fi
cd "$WORKSPACE/android"
# enforce non-root
if [ "$(id -u)" -eq 0 ]; then echo "ERROR: do not run validation build as root" >&2; exit 2; fi
# detect AGP plugin in app module sources
if ! grep -qE "com.android.application|com.android.library|id\(['\"]com.android.application|id\(['\"]com.android.library" -R app 2>/dev/null; then echo -e "STATUS=SKIPPED\nREASON=placeholder android scaffold (no AGP plugin)" > "$OUT_RESULT" && exit 0; fi
# choose gradle invocation
if [ -x ./gradlew ]; then CMD=(./gradlew); elif command -v gradle >/dev/null 2>&1; then CMD=(gradle); else echo -e "STATUS=SKIPPED\nREASON=no gradle or gradlew available" > "$OUT_RESULT" && exit 0; fi
# build (assembleDebug) non-interactively
"${CMD[@]}" assembleDebug --no-daemon >/dev/null 2>&1 || { echo -e "STATUS=FAIL\nREASON=gradle build failed" > "$OUT_RESULT"; exit 3; }
# locate apk/aab
APK=""
for p in app/build/outputs/apk/*/app-*-debug.apk app/build/outputs/bundle/*/*.aab; do for f in $p; do [ -f "$f" ] && { APK="$f"; break 2; } done; done
if [ -z "$APK" ]; then APK=$(find . -type f \( -iname "*.apk" -o -iname "*.aab" \) -print -quit || true); fi
if [ -z "$APK" ]; then echo -e "STATUS=FAIL\nREASON=no apk/aab found" > "$OUT_RESULT"; exit 4; fi
# record artifact metadata
size=$(stat -c%s "$APK" || echo 0)
sha=$(sha256sum "$APK" | awk '{print $1}' || echo "")
mtime=$(stat -c%y "$APK" || echo "")
echo "artifact=$APK" > "$EVIDENCE_FILE"
echo "size=$size" >> "$EVIDENCE_FILE"
echo "sha256=$sha" >> "$EVIDENCE_FILE"
echo "mtime=$mtime" >> "$EVIDENCE_FILE"
# find apksigner: prefer PATH, else ANDROID_SDK_ROOT/build-tools/latest
APKSIGNER_CMD=$(command -v apksigner || true)
if [ -z "$APKSIGNER_CMD" ] && [ -n "${ANDROID_SDK_ROOT:-}" ] && [ -d "$ANDROID_SDK_ROOT/build-tools" ]; then
  latest_bt=$(ls -1 "$ANDROID_SDK_ROOT/build-tools" | sort -V | tail -n1 2>/dev/null || true)
  if [ -n "$latest_bt" ] && [ -x "$ANDROID_SDK_ROOT/build-tools/$latest_bt/apksigner" ]; then APKSIGNER_CMD="$ANDROID_SDK_ROOT/build-tools/$latest_bt/apksigner"; fi
fi
# verify with apksigner or fallback to dex check
if [ -n "$APKSIGNER_CMD" ] && [ -x "$APKSIGNER_CMD" ]; then
  if "$APKSIGNER_CMD" verify --print-certs "$APK" >/dev/null 2>&1; then echo "APKSIGNER=OK" >> "$EVIDENCE_FILE"; else echo "APKSIGNER=FAILED" >> "$EVIDENCE_FILE" && echo -e "STATUS=FAIL\nREASON=apksigner verify failed" > "$OUT_RESULT" && exit 5; fi
else
  if unzip -l "$APK" 2>/dev/null | grep -q "classes.dex"; then echo "DEX_PRESENT=YES" >> "$EVIDENCE_FILE"; else echo "DEX_PRESENT=NO" >> "$EVIDENCE_FILE" && echo -e "STATUS=FAIL\nREASON=classes.dex missing" > "$OUT_RESULT" && exit 6; fi
fi
# basic manifest check
if unzip -l "$APK" 2>/dev/null | grep -q "AndroidManifest.xml"; then echo "MANIFEST_PRESENT=YES" >> "$EVIDENCE_FILE"; else echo "MANIFEST_PRESENT=NO" >> "$EVIDENCE_FILE"; fi
# stop gradle daemons if wrapper present
if [ -x ./gradlew ]; then ./gradlew --stop >/dev/null 2>&1 || true; fi
# success
echo -e "STATUS=PASS\nREASON=artifact built and smoke-checked" > "$OUT_RESULT"
echo "validation complete; evidence in $EVIDENCE_FILE"
