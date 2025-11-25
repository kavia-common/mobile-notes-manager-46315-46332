#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
mkdir -p "$WORKSPACE/.tool_logs"
# Flutter path check and pub get
if [ -f "pubspec.yaml" ]; then
  if [ ! -x "/opt/flutter/bin/flutter" ]; then
    echo "flutter missing at /opt/flutter/bin/flutter" >&2
    echo "flutter missing" > "$WORKSPACE/.tool_logs/flutter_missing.txt"
    exit 40
  fi
  /opt/flutter/bin/flutter --version > "$WORKSPACE/.tool_logs/flutter_version.txt" 2>&1 || true
  /opt/flutter/bin/flutter pub get > "$WORKSPACE/.tool_logs/flutter_pub_get.txt" 2>&1 || { echo 'flutter pub get failed' >&2; exit 41; }
  exit 0
fi
# Node/JS dependency install
if [ -f "package.json" ]; then
  # If project likely React Native, require Node >=14
  if grep -q "react-native" package.json 2>/dev/null; then
    if node -e "process.exit( (parseInt(process.versions.node.split('.')[0])>=14)?0:1 )" 2>/dev/null; then :; else
      echo 'Node 14+ required for React Native projects' >&2
      echo 'Node <14' > "$WORKSPACE/.tool_logs/node_version_too_old.txt"
      exit 42
    fi
  fi
  # Prefer yarn frozen when yarn.lock present and yarn available
  if [ -f yarn.lock ] && command -v yarn >/dev/null 2>&1; then
    yarn --silent --frozen-lockfile > "$WORKSPACE/.tool_logs/yarn_install.txt" 2>&1 || { echo 'yarn install failed' >&2; exit 43; }
  elif [ -f package-lock.json ]; then
    npm ci --silent --no-audit --no-fund > "$WORKSPACE/.tool_logs/npm_ci.txt" 2>&1 || { echo 'npm ci failed' >&2; exit 44; }
  else
    npm i --silent --no-audit --no-fund > "$WORKSPACE/.tool_logs/npm_i.txt" 2>&1 || { echo 'npm install failed' >&2; exit 45; }
  fi
fi
# ensure android gradle wrapper exists when android folder present
if [ -d android ] && [ ! -f android/gradlew ]; then
  echo 'android/gradlew (gradle wrapper) missing; provide wrapper or run Gradle on host/CI' > "$WORKSPACE/.tool_logs/gradle_wrapper_missing.txt"
  echo 'gradle wrapper missing' >&2
  exit 46
fi

# If nothing to do, exit 0
exit 0
