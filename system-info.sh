#!/usr/bin/env bash
set -uo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd) || exit 1
mkdir -p "$SCRIPT_DIR/logs"
log() { printf '%s | system-info | %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$SCRIPT_DIR/logs/operations.log"; }
log 'Started system information collection'
value() { local output; if output=$("$@" 2>/dev/null); then printf '%s' "$output"; else printf 'Unavailable'; fi; }
printf 'Hostname: %s\n' "$(value hostname)"
printf 'User: %s\n' "$(value whoami)"
printf 'Date/Time: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
if [[ -r /etc/os-release ]]; then . /etc/os-release; printf 'Operating System: %s\n' "${PRETTY_NAME:-Unknown}"; else printf 'Operating System: %s\n' "$(value uname -s)"; fi
printf 'Kernel: %s\n' "$(value uname -r)"
printf 'Uptime: %s\n' "$(uptime -p 2>/dev/null || uptime)"
printf 'CPU: %s\n' "$(awk -F: '/^model name[[:space:]]*:/ {sub(/^[[:space:]]+/, "", $2); print $2; exit}' /proc/cpuinfo 2>/dev/null || true)"
printf 'CPU Cores: %s\n' "$(getconf _NPROCESSORS_ONLN 2>/dev/null || printf 'Unknown')"
if command -v free >/dev/null 2>&1; then free -h | awk '/^Mem:/ {printf "Memory: %s total, %s used, %s available\n", $2, $3, $7}'; else awk '/MemTotal:/ {printf "Memory: %.1f GiB total\n", $2/1048576}' /proc/meminfo; fi
printf 'Working Directory: %s\n' "$PWD"
log 'Completed system information collection'
