#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
mkdir -p "$SCRIPT_DIR/logs"
log() { printf '%s | network-check | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$SCRIPT_DIR/logs/operations.log"; }
usage() { echo 'Usage: ./network-check.sh <hostname> [port]' >&2; }
if (( $# < 1 || $# > 2 )) || [[ -z ${1:-} ]]; then usage; log 'Missing or extra arguments'; exit 2; fi
host=$1
if [[ $host == -* || $host =~ [[:space:]] || $host == *'/'* ]]; then echo 'Error: invalid hostname.' >&2; log 'Invalid hostname'; exit 2; fi
port=${2:-}
if [[ -n $port ]]; then
  if [[ ! $port =~ ^[0-9]+$ ]] || (( ${#port} > 5 )) || (( 10#$port < 1 || 10#$port > 65535 )); then echo 'Error: port must be an integer from 1 to 65535.' >&2; log "Invalid port: $port"; exit 2; fi
  port=$((10#$port))
fi
if ! command -v getent >/dev/null 2>&1; then echo 'Error: getent is unavailable.' >&2; log 'getent unavailable'; exit 1; fi
resolved=$(getent ahosts "$host" 2>/dev/null | awk 'NR==1 {print $1}')
if [[ -z $resolved ]]; then echo "Error: cannot resolve host: $host" >&2; log "DNS resolution failed: $host"; exit 1; fi
printf 'Host: %s\nResolved address: %s\n' "$host" "$resolved"
log "Resolved $host to $resolved"
if command -v ping >/dev/null 2>&1; then
  if ping -n -c 1 -W 2 "$host" >/dev/null 2>&1; then echo 'Ping: successful'; log "Ping successful: $host"; else echo 'Ping: unsuccessful (ICMP may be blocked)'; log "Ping unsuccessful: $host"; fi
else echo 'Ping: unavailable'; log 'Ping utility unavailable'; fi
if [[ -n $port ]]; then
  if command -v timeout >/dev/null 2>&1 && timeout 3 bash -c 'exec 3<>/dev/tcp/"$1"/"$2"' _ "$host" "$port" 2>/dev/null; then
    echo "TCP port $port: reachable"; log "TCP reachable: $host:$port"
  else
    echo "TCP port $port: unreachable" >&2; log "TCP unreachable: $host:$port"; exit 1
  fi
fi
exit 0
