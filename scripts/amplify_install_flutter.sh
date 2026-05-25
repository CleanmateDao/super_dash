#!/usr/bin/env bash
# Installs Flutter (stable) on Amplify build hosts. Idempotent via FLUTTER_HOME cache.
set -euo pipefail

FLUTTER_HOME="${FLUTTER_HOME:-${HOME}/flutter}"

if [[ ! -x "${FLUTTER_HOME}/bin/flutter" ]]; then
  echo "Cloning Flutter stable into ${FLUTTER_HOME}"
  rm -rf "${FLUTTER_HOME}"
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "${FLUTTER_HOME}"
fi

export PATH="${FLUTTER_HOME}/bin:${PATH}"

flutter config --enable-web --no-analytics
flutter --version
flutter pub get
