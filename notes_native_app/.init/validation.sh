#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
mkdir -p "$WORKSPACE/.validation_logs"
ANDR_ROOT="${ANDROID_SDK_ROOT:-/opt/android-sdk}"
ADB_PATH="$ANDR_ROOT/platform-tools/adb"
# Log java version
java -version 2>&1 | head -n1 > "$WORKSPACE/.validation_logs/java_version.txt" || true
# Build APK
APK_PATH=""
if [ -f "pubspec.yaml" ]; then
  /opt/flutter/bin/flutter build apk --debug --no-shrink > "$WORKSPACE/.validation_logs/flutter_build.txt" 2>&1 || { echo 'flutter build failed' >&2; exit 60; }
  APK_PATH=$(find build -type f -name "*-debug.apk" | head -n1 || true)
elif [ -f "package.json" ]; then
  if [ -d android ] && [ -f android/gradlew ]; then
    (cd android && ./gradlew assembleDebug -q) > "$WORKSPACE/.validation_logs/gradle_build.txt" 2>&1 || { echo 'gradle build failed' >&2; exit 61; }
    APK_PATH=$(find android -path "*/outputs/apk/*/debug/*.apk" | head -n1 || true)
  else
    echo 'No android/gradlew to build APK; skipping APK build' > "$WORKSPACE/.validation_logs/no_apk.txt"
  fi
fi
if [ -n "$APK_PATH" ] && [ -f "$APK_PATH" ]; then
  echo "$APK_PATH" > "$WORKSPACE/.validation_logs/built_apk_path.txt"
else
  echo 'No APK artifact found; will skip device install/start' > "$WORKSPACE/.validation_logs/no_apk_found.txt"
fi
# Check adb availability (non-fatal)
if [ ! -x "$ADB_PATH" ] && ! command -v adb >/dev/null 2>&1; then
  echo 'adb not available; skipping install/start' > "$WORKSPACE/.validation_logs/adb_missing.txt"
  exit 0
fi
ADB_CMD=""
if [ -x "$ADB_PATH" ]; then ADB_CMD="$ADB_PATH"; else ADB_CMD=$(command -v adb); fi
$ADB_CMD version > "$WORKSPACE/.validation_logs/adb_version.txt" 2>&1 || true
DEVLIST=$($ADB_CMD devices | sed '1d' | awk '{print $1}' | grep -v '^$' || true)
if [ -z "$DEVLIST" ]; then
  echo 'No adb devices connected; skipping install/start' > "$WORKSPACE/.validation_logs/no_devices.txt"
  exit 0
fi
DEVICE=$(echo "$DEVLIST" | head -n1)
# If we have an APK, try to install/start
if [ -n "$APK_PATH" ] && [ -f "$APK_PATH" ]; then
  $ADB_CMD -s "$DEVICE" install -r "$APK_PATH" > "$WORKSPACE/.validation_logs/adb_install.txt" 2>&1 || { echo 'adb install failed' >&2; exit 62; }
  # find aapt/apkanalyzer or fallback
  AAPT=""
  if [ -x "$ANDR_ROOT/build-tools/33.0.2/aapt" ]; then AAPT="$ANDR_ROOT/build-tools/33.0.2/aapt"; fi
  if [ -z "$AAPT" ]; then
    AAPT=$(find "$ANDR_ROOT/build-tools" -maxdepth 2 -type f \( -name aapt -o -name aapt2 \) | head -n1 || true)
  fi
  APKANALYZER=$(command -v apkanalyzer 2>/dev/null || true)
  PKG=""
  ACT=""
  if [ -n "$AAPT" ] && [ -x "$AAPT" ]; then
    PKG=$($AAPT dump badging "$APK_PATH" | awk -F"'" '/package: name=/{print $2; exit}') || true
    ACT=$($AAPT dump badging "$APK_PATH" | awk -F"'" '/launchable-activity: name=/{print $2; exit}') || true
  elif [ -n "$APKANALYZER" ]; then
    PKG=$(apkanalyzer manifest print --apk "$APK_PATH" 2>/dev/null | awk -F'package="' '/package=/{print $2; exit}' | cut -d'"' -f1) || true
  else
    if command -v unzip >/dev/null 2>&1; then
      unzip -p "$APK_PATH" AndroidManifest.xml 2>/dev/null | strings | tr -d '\0' | grep -o 'package="[^"]*"' | head -n1 | sed 's/package="//;s/"//' > "$WORKSPACE/.validation_logs/manifest_pkg.txt" || true
      PKG=$(cat "$WORKSPACE/.validation_logs/manifest_pkg.txt" 2>/dev/null || true)
    fi
  fi
  if [ -n "$PKG" ]; then
    if [ -n "$ACT" ]; then
      $ADB_CMD -s "$DEVICE" shell am start -n "$PKG/$ACT" > "$WORKSPACE/.validation_logs/adb_start.txt" 2>&1 || true
    fi
    sleep 2
    if $ADB_CMD -s "$DEVICE" shell ps -A | tr -d '\r' | grep -F "$PKG" >/dev/null 2>&1; then
      echo "app $PKG running on $DEVICE" > "$WORKSPACE/.validation_logs/app_running.txt"
    else
      echo "app $PKG not detected via ps" > "$WORKSPACE/.validation_logs/app_not_running.txt"
    fi
    $ADB_CMD -s "$DEVICE" logcat -d > "$WORKSPACE/adb_log_${DEVICE}.txt" || true
    $ADB_CMD -s "$DEVICE" shell am force-stop "$PKG" || true
    $ADB_CMD -s "$DEVICE" uninstall "$PKG" || true
  else
    echo 'Could not determine package name; installed APK but skipping start/uninstall steps' > "$WORKSPACE/.validation_logs/could_not_determine_pkg.txt"
  fi
else
  echo 'No APK to install' > "$WORKSPACE/.validation_logs/no_apk_to_install.txt"
fi
exit 0
