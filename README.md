# Assignment 1 — Linux, Bash & Networking

A Linux diagnostic toolkit written in Bash. All system information and measurements are obtained at runtime.

## Requirements

- Linux (Ubuntu under WSL is supported)
- Bash, coreutils, `df`, `awk`, `getent`, `hostname`, `uptime`, `free`
- `ping` (recommended; ICMP can be blocked by the network)
- Git for submission

On Ubuntu, install common utilities if needed:

```bash
sudo apt update
sudo apt install -y git iputils-ping netcat-openbsd
```

## Setup

```bash
chmod +x system-info.sh disk-check.sh network-check.sh grade.sh
./system-info.sh
./disk-check.sh
./network-check.sh localhost
```

## Usage

### `system-info.sh`

```bash
./system-info.sh
```

Shows hostname, user, date/time, operating system, kernel version, uptime, CPU, memory and the current working directory.

### `disk-check.sh`

```bash
./disk-check.sh             # defaults: threshold=80, path=/
./disk-check.sh 90
./disk-check.sh 75 /home
```

Shows the usage percentage of the filesystem containing the selected path. Returns `0` if usage is below the threshold, `1` if usage meets/exceeds the threshold or cannot be read, and `2` for invalid input. The threshold must be an integer from 1 through 100.

### `network-check.sh`

```bash
./network-check.sh localhost
./network-check.sh localhost 22
./network-check.sh example.com 443
```

Resolves the hostname using `getent`, attempts an ICMP ping, and optionally checks a TCP port. TCP port values must be integers from 1 through 65535. Exit codes: `0` on successful resolution and (if requested) TCP connectivity, `1` on operational failure, and `2` for invalid input. ICMP may be blocked even when TCP connectivity works; a failed ping alone does not fail the check.

## Logging

Each script appends timestamped operation descriptions to `logs/operations.log`. The log directory is created automatically. Generated `.log` files are ignored by Git.

## Local testing

```bash
./grade.sh
bash -n system-info.sh disk-check.sh network-check.sh
./disk-check.sh 0; echo "Exit code: $?"       # 2
./disk-check.sh 101; echo "Exit code: $?"     # 2
./network-check.sh; echo "Exit code: $?"     # 2
./network-check.sh localhost 0; echo "Exit code: $?" # 2
./network-check.sh localhost 65536; echo "Exit code: $?" # 2
```

`grade.sh` is a local self-check based on the assignment's published grading expectations, not a substitute for the instructor's original grading script.

## Git workflow

Run the included `setup-git.sh` once in this directory to initialize a repository with at least five meaningful commits, a feature branch and a merge to `main`. Then create a **separate** empty GitHub repository and add its URL as `origin`:

```bash
./setup-git.sh
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

If your default Git branch is `master`, the setup script renames it to `main`. Set `git config --global user.name` and `git config --global user.email` before running it if Git identity is not configured.

## Assumptions

- Disk usage is the percentage reported by `df -P` for the filesystem containing the requested path.
- Threshold equality is considered a warning (`usage >= threshold`).
- A TCP connection attempt has a three-second timeout.
- WSL environments may restrict ICMP echo requests; DNS resolution and requested TCP connectivity are evaluated separately.
- The scripts do not require machine-specific values or credentials.
