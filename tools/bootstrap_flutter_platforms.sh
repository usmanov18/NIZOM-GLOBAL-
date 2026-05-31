#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "ERROR: flutter CLI not found. Install Flutter first."
  exit 1
fi

echo "Bootstrapping Flutter platform folders..."

# Keep existing project files, but ask Flutter to regenerate missing platform scaffolding.
# Existing AndroidManifest/Info.plist/google-services files should be reviewed after this.
if [[ ! -f android/settings.gradle || ! -f android/app/build.gradle ]]; then
  flutter create --platforms=android .
else
  echo "Android scaffold already present."
fi

if [[ ! -f ios/Runner.xcodeproj/project.pbxproj ]]; then
  flutter create --platforms=ios .
else
  echo "iOS scaffold already present."
fi

echo "Platform bootstrap completed. Review platform config files before committing."
