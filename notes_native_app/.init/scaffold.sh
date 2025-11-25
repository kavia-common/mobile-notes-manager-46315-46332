#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
[ -f README.md ] || echo "Mobile notes manager - placeholder workspace" > README.md
if [ ! -d "$WORKSPACE/android" ]; then
  mkdir -p "$WORKSPACE/android/app/src/main/java/com/example/notes" "$WORKSPACE/android/app/src/main/res"
  cat > "$WORKSPACE/android/settings.gradle" <<'EOF'
rootProject.name = 'notes_native_app'
include ':app'
EOF
  cat > "$WORKSPACE/android/build.gradle" <<'EOF'
// Placeholder top-level build file. Replace with real AGP configuration when available.
allprojects { repositories { mavenCentral(); google() } }
EOF
  cat > "$WORKSPACE/android/app/build.gradle" <<'EOF'
// Placeholder module. Provide a real Android module with 'com.android.application' or 'com.android.library' to enable builds.
// No plugins applied intentionally to keep this scaffold safe for automated pipelines.
repositories { mavenCentral() }
EOF
fi
cat > "$WORKSPACE/start.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "${WORKSPACE}/android" || { echo "SKIPPED: no android dir" > "${WORKSPACE}/.start_status"; exit 0; }
if [ "$(id -u)" -eq 0 ]; then echo "ERROR: do not run build as root" >&2; exit 2; fi
if grep -E "apply plugin:|id\(\s*'com.android.application'|id\(\s*\"com.android.application\"|com.android.application|com.android.library" -r app 2>/dev/null | grep -q "com.android"; then
  if [ -x ./gradlew ]; then ./gradlew assembleDebug --no-daemon || { echo "BUILD_FAILED" > "${WORKSPACE}/.start_status"; exit 3; }
  elif command -v gradle >/dev/null 2>&1; then gradle assembleDebug --no-daemon || { echo "BUILD_FAILED" > "${WORKSPACE}/.start_status"; exit 4; }
  else echo "SKIPPED: gradle not available" > "${WORKSPACE}/.start_status"; exit 0; fi
  echo "BUILD_TRIGGERED" > "${WORKSPACE}/.start_status"
else
  echo "SKIPPED: placeholder project (no AGP plugin)" > "${WORKSPACE}/.start_status"
fi
EOF
chmod +x "$WORKSPACE/start.sh"
