#!/usr/bin/env bash
set -euo pipefail

dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
flutter build apk --release

apk_path="build/app/outputs/flutter-apk/app-release.apk"
test -s "$apk_path"
unzip -t "$apk_path" >/dev/null

echo "Verified formatting, analysis, tests, release build, and APK integrity."
