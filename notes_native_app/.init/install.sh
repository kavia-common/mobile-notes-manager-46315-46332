#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
# Enforce non-root execution
if [ "$(id -u)" -eq 0 ]; then echo "ERROR: run dependency installation as non-root user" >&2; exit 2; fi
# Ensure Node/npm present
command -v node >/dev/null 2>&1 || { echo "ERROR: node missing" >&2; exit 3; }
command -v npm >/dev/null 2>&1 || { echo "ERROR: npm missing" >&2; exit 4; }
# Install Node deps non-interactively: prefer npm ci when lockfile present
if [ -f package.json ]; then
  if [ -f package-lock.json ]; then npm ci --silent --no-audit --no-fund; else npm i --silent --no-audit --no-fund; fi
fi
# .NET restore for solution files (dotnet-sdk-8.0 is present per image)
if ls *.sln >/dev/null 2>&1; then command -v dotnet >/dev/null 2>&1 || { echo "ERROR: dotnet missing" >&2; exit 6; }; dotnet restore --verbosity minimal; fi
# Android: detect AGP usage inside android/app; if present ensure gradlew or system gradle exists
if [ -d "$WORKSPACE/android/app" ]; then
  if grep -qE "com.android.application|com.android.library|id\(['\"]com.android.application|id\(['\"]com.android.library" -R "$WORKSPACE/android/app" 2>/dev/null; then
    cd "$WORKSPACE/android"
    if [ -x ./gradlew ]; then ./gradlew -v >/dev/null; else
      if ! command -v gradle >/dev/null 2>&1; then
        echo "ERROR: gradle not available and gradlew missing; to enable full Android validation set ENABLE_ANDROID_SDK=1 and ensure gradle or gradlew present" >&2
        exit 5
      fi
      gradle -v >/dev/null
    fi
  fi
fi
# End
