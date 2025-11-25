#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
if [ -f android/gradlew ]; then
  (cd android && ./gradlew assembleDebug -q) || exit 1
else
  echo "Missing android/gradlew — ensure project provides gradle wrapper" >&2
  exit 32
fi
