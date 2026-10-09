#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
mkdir -p "$SCRIPT_DIR/logs"
log() { printf '%s | disk-check | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$SCRIPT_DIR/logs/operations.log"; }
usage() { echo 'Usage: ./disk-check.sh [threshold 1-100] [path]' >&2; }
if (( $# > 2 )); then usage; log 'Invalid argument count'; exit 2; fi
threshold=${1:-80}
path=${2:-/}
if [[ ! $threshold =~ ^[0-9]+$ ]] || (( ${#threshold} > 3 )) || (( 10#$threshold < 1 || 10#$threshold > 100 )); then usage; echo 'Error: threshold must be an integer from 1 to 100.' >&2; log "Invalid threshold: $threshold"; exit 2; fi
threshold=$((10#$threshold))
if [[ ! -e $path ]]; then echo "Error: path does not exist: $path" >&2; log "Invalid path: $path"; exit 2; fi
usage_percent=$(df -P "$path" 2>/dev/null | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
if [[ ! $usage_percent =~ ^[0-9]+$ ]]; then echo 'Error: unable to read disk usage.' >&2; log 'Disk usage read failed'; exit 1; fi
printf 'Disk usage: %s%%\nThreshold: %s%%\nPath: %s\n' "$usage_percent" "$threshold" "$path"
if (( usage_percent >= threshold )); then echo "WARNING: disk usage reached or exceeded threshold."; log "WARNING usage=${usage_percent}% threshold=${threshold}% path=$path"; exit 1; fi
echo 'OK: disk usage is below threshold.'
log "OK usage=${usage_percent}% threshold=${threshold}% path=$path"
exit 0
