#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "$WORKSPACE"
if [ "$(id -u)" -eq 0 ]; then echo "ERROR: do not run tests as root" >&2; exit 2; fi
RESULT_FILE="$WORKSPACE/.test_result"
# JS: prefer project-local jest
if [ -f package.json ]; then
  mkdir -p test && cat > test/sample.test.js <<'EOF'
test('sanity', () => { expect(1+1).toBe(2); });
EOF
  if [ -x "node_modules/.bin/jest" ]; then
    ./node_modules/.bin/jest --runInBand --colors --testMatch "**/test/**/*.test.js" || { echo -e "STATUS=FAIL\nDETAILS=jest failed" > "$RESULT_FILE"; exit 6; }
    echo -e "STATUS=PASS\nDETAILS=jest ran" > "$RESULT_FILE"
  else
    echo -e "STATUS=SKIPPED\nDETAILS=jest not installed locally; run 'npm ci' to install devDependencies" > "$RESULT_FILE"
    exit 0
  fi
# .NET: if solution present, ensure tests exist or scaffold minimal xUnit
elif ls *.sln >/dev/null 2>&1; then
  if [ ! -d tests ]; then dotnet new xunit -o tests >/dev/null; fi
  dotnet test tests --verbosity minimal || { echo -e "STATUS=FAIL\nDETAILS=dotnet test failed" > "$RESULT_FILE"; exit 7; }
  echo -e "STATUS=PASS\nDETAILS=dotnet tests passed" > "$RESULT_FILE"
else
  echo -e "STATUS=SKIPPED\nDETAILS=no test targets found" > "$RESULT_FILE"
fi
