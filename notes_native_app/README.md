# Ocean Notes (Native)

A clean, modern offline-first notes application for mobile devices, built with Expo React Native. It implements the Ocean Professional theme with blue primary accents and amber secondary highlights.

## Features
- Notes list with search, preview, and last updated timestamp
- Create, edit, view, and delete notes
- Local persistence (AsyncStorage) — fully offline
- Pull-to-refresh on list
- Snackbar feedback for save/delete/errors
- Input validation (requires title or content)
- Accessibility labels for primary actions
- Basic unit tests for the repository

## Theme
- Primary: #2563EB
- Secondary/Success: #F59E0B
- Error: #EF4444
- Background: #f9fafb
- Surface: #ffffff
- Text: #111827
- Subtle rounded corners, soft shadows, and smooth interactions

## Architecture at a glance
- src/models: Note type
- src/storage: INoteRepository interface and AsyncStorage implementation (swappable)
- src/screens: NotesList, NoteEditor, ViewNote
- src/components: Button, FAB, SearchBar, Snackbar
- src/theme: Theme constants
- src/App.tsx: Navigation and theme setup

## Local storage choice
AsyncStorage is used for simple, reliable on-device persistence. The repository is abstracted so you can later switch to SQLite or other storage without changing UI code.

## Getting started

1. Install dependencies:
   - npm install
2. Start the app:
   - npm run start
3. Run on a device or simulator:
   - Press `a` for Android emulator, `i` for iOS simulator (on macOS), or scan the QR code in Expo Go.

## Running tests
- npm test

## Notes
- No external services or environment variables are required.
- All app code is self-contained within this `notes_native_app` container.

## Future improvements
- Tagging and folders
- Rich text or markdown support
- Sync/export options
