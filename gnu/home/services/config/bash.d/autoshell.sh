#!/usr/bin/env bash
set -euo pipefail

# Run the given command via 'guix shell'
function ,() {
    local pkg

    pkg=$(
        guix locate "$1" |
        awk '/\/bin\// {
            sub(/@.*/, "", $1)
            print $1
            exit
        }'
    )

    [ -n "$pkg" ] && guix shell "$pkg" -- "$@"
}
