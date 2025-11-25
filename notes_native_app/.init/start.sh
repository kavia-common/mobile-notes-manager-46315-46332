#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
cd "/home/kavia/workspace/code-generation/mobile-notes-manager-46315-46332/notes_native_app"
npm run start --silent || npx react-native start
