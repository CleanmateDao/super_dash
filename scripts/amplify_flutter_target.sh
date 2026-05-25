#!/usr/bin/env bash
# Resolves lib/main_*.dart entry point for the current Amplify branch.
# Override with AMPLIFY_FLUTTER_TARGET (e.g. lib/main_prod.dart).
set -euo pipefail

if [[ -n "${AMPLIFY_FLUTTER_TARGET:-}" ]]; then
  echo "${AMPLIFY_FLUTTER_TARGET}"
  exit 0
fi

branch="${AWS_BRANCH:-}"

case "${branch}" in
  production | prod)
    echo "lib/main_prod.dart"
    ;;
  staging | stage)
    echo "lib/main_tester.dart"
    ;;
  *)
    # main and feature branches — matches Firebase dev deploy workflow
    echo "lib/main_dev.dart"
    ;;
esac
