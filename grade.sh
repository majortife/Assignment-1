#!/usr/bin/env bash
set -uo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1
PASS=0; FAIL=0
pass() { echo "PASS: $1"; PASS=$((PASS+1)); }
fail() { echo "FAIL: $1"; FAIL=$((FAIL+1)); }
for f in README.md system-info.sh disk-check.sh network-check.sh; do
  [[ -f $f ]] && pass "Required file: $f" || fail "Missing required file: $f"
done
mkdir -p logs
for f in system-info.sh disk-check.sh network-check.sh; do
  bash -n "$f" && pass "Bash syntax: $f" || fail "Bash syntax: $f"
  [[ -x $f ]] && pass "Executable: $f" || fail "Not executable: $f"
done
if output=$(./system-info.sh 2>&1); then
  pass 'system-info exits successfully'
  for word in Hostname User Kernel Uptime; do
    grep -qi "$word" <<< "$output" && pass "system-info contains $word" || fail "system-info missing $word"
  done
else fail 'system-info failed'; fi
check_exit() { local expected=$1 name=$2; shift 2; "$@" >/dev/null 2>&1; local actual=$?; [[ $actual -eq $expected ]] && pass "$name" || fail "$name (expected $expected, got $actual)"; }
check_exit 2 'disk rejects threshold 0' ./disk-check.sh 0
check_exit 2 'disk rejects threshold 101' ./disk-check.sh 101
check_exit 2 'disk rejects nonnumeric threshold' ./disk-check.sh abc
check_exit 0 'disk accepts valid threshold' ./disk-check.sh 100 /
check_exit 2 'network rejects missing host' ./network-check.sh
check_exit 0 'network resolves localhost' ./network-check.sh localhost
check_exit 2 'network rejects port 0' ./network-check.sh localhost 0
check_exit 2 'network rejects port 65536' ./network-check.sh localhost 65536
check_exit 2 'network rejects nonnumeric port' ./network-check.sh localhost abc
find logs -type f -name '*.log' -print -quit | grep -q . && pass 'Log file created' || fail 'No log file created'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  commits=$(git rev-list --count HEAD 2>/dev/null || echo 0)
  [[ $commits -ge 5 ]] && pass 'At least five commits' || fail 'Fewer than five commits'
  branches=$(git for-each-ref --format='%(refname:short)' refs/heads)
  if grep -q 'feature/' <<< "$branches" || git log --all --oneline --grep='Merge feature/' | grep -q .; then pass 'Feature branch history'; else echo 'WARN: Review feature branch and merge history'; fi
else echo 'WARN: Git history not initialized yet'; fi
printf '\nPassed: %s | Failed: %s\n' "$PASS" "$FAIL"
(( FAIL == 0 ))
