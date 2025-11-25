#!/usr/bin/env bash
set -euo pipefail
# scaffolding step: detect Flutter or React Native, install Flutter stable into /opt/flutter, create helper scripts
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
mkdir -p "$WORKSPACE/.tool_logs"
LOCKFILE="/var/lock/notes_native_app_setup.lock"
exec 9>"$LOCKFILE" || exit 11
flock 9 || true
# Flutter detection
if [ -f "$WORKSPACE/pubspec.yaml" ]; then
  if [ ! -d "/opt/flutter" ]; then
    TMPDIR=$(mktemp -d)
    git clone --depth 1 --branch stable https://github.com/flutter/flutter.git "$TMPDIR/flutter" > "$WORKSPACE/.tool_logs/flutter_clone.txt" 2>&1 || (rm -rf "$TMPDIR" && echo 'flutter clone failed' >&2 && exit 30)
    sudo rm -rf /opt/flutter || true
    sudo mv "$TMPDIR/flutter" /opt/flutter
    sudo chown -R "$(id -u):$(id -g)" /opt/flutter
    sudo chmod -R a+rx /opt/flutter || true
    rm -rf "$TMPDIR"
  fi
  sudo tee /etc/profile.d/flutter.sh >/dev/null <<'EOF'
export FLUTTER_ROOT="/opt/flutter"
export FLUTTER_HOME="/opt/flutter"
export PATH="/opt/flutter/bin:$PATH"
EOF
  sudo chmod 644 /etc/profile.d/flutter.sh
  # load for current shell if possible
  # shellcheck disable=SC1090
  source /etc/profile.d/flutter.sh 2>/dev/null || true
  /opt/flutter/bin/flutter --version > "$WORKSPACE/.tool_logs/flutter_version.txt" 2>&1 || { echo 'flutter missing or failed --version' >&2; exit 31; }
  # canonical start script
  cat > "$WORKSPACE/.init/start.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
/opt/flutter/bin/flutter run --no-sound-null-safety || true
SH
  chmod +x "$WORKSPACE/.init/start.sh"
  # canonical build script for flutter
  cat > "$WORKSPACE/.init/build.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
/opt/flutter/bin/flutter build apk --debug -v || exit 1
SH
  chmod +x "$WORKSPACE/.init/build.sh"
else
  # React Native detection
  if [ -f "$WORKSPACE/package.json" ]; then
    if node -e "const p=require('./package.json'); const deps=Object.assign({}, p.dependencies||{}, p.devDependencies||{}); const found=Object.keys(deps).some(k=>k==='react-native' || k.startsWith('react-native/')); process.exit(found?0:1)" 2>/dev/null; then
      # choose start command: prefer yarn when yarn.lock exists and yarn available
      if [ -f "$WORKSPACE/yarn.lock" ] && command -v yarn >/dev/null 2>&1; then
        START_CMD='yarn start'
      else
        START_CMD='npm run start --silent'
      fi
      cat > "$WORKSPACE/.init/start.sh" <<SH
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
$START_CMD || npx react-native start
SH
      cat > "$WORKSPACE/.init/build.sh" <<'SH'
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
SH
      chmod +x "$WORKSPACE/.init/start.sh" "$WORKSPACE/.init/build.sh"
    else
      cat > "$WORKSPACE/.init/start.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
echo "No recognized mobile framework files found. Place your project files in the workspace."
SH
      chmod +x "$WORKSPACE/.init/start.sh"
    fi
  else
    cat > "$WORKSPACE/.init/start.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
echo "No recognized mobile framework files found. Place your project files in the workspace."
SH
    chmod +x "$WORKSPACE/.init/start.sh"
  fi
fi
flock -u 9 || true
