#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$ROOT"

# shellcheck source=scripts/common.sh
source "$ROOT/scripts/common.sh"

require_user
require_debian12

case "${1:-desktop}" in
    desktop)
        bash "$ROOT/scripts/install-packages.sh"
        bash "$ROOT/scripts/configure-user.sh"
        ;;
    packages)
        bash "$ROOT/scripts/install-packages.sh"
        ;;
    configure)
        bash "$ROOT/scripts/configure-user.sh"
        ;;
    tlp)
        bash "$ROOT/scripts/install-tlp.sh"
        ;;
    check)
        bash "$ROOT/scripts/check.sh"
        ;;
    *)
        printf 'Usage: %s {desktop|packages|configure|surface|tlp|check}\n' "$0" >&2
        exit 2
        ;;
esac
