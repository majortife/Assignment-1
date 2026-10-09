# Assignment 1 - Linux, Bash & Networking

This project contains three Bash scripts for checking Linux system information, disk usage, and network connectivity.

## Requirements

- Linux (Ubuntu or WSL)
- Bash
- Git
- Basic Linux utilities such as `df`, `awk`, `getent`, `free`, and `ping`

Install any missing utilities on Ubuntu using:

```bash
sudo apt update
sudo apt install -y git iputils-ping netcat-openbsd
```

## Setup

Clone the repository and move into the project directory.

Give the scripts executable permissions:

```bash
chmod +x system-info.sh disk-check.sh network-check.sh grade.sh
```

## Running the Scripts

### 1. System Information

```bash
./system-info.sh
```

Displays basic system details, including:

- Hostname and current user
- Date and time
- Operating system and kernel version
- System uptime
- CPU and memory information
- Current working directory

### 2. Disk Usage Check

```bash
./disk-check.sh
```

Checks disk usage using a default threshold of 80%.

You can also specify a threshold and directory:

```bash
./disk-check.sh 90
./disk-check.sh 75 /home
```

The threshold must be between 1 and 100.

Exit codes:

- `0` - Disk usage is below the threshold
- `1` - Disk usage has reached the threshold or the check failed
- `2` - Invalid input

### 3. Network Check

```bash
./network-check.sh localhost
```

Checks whether a hostname can be resolved and attempts to ping it.

You can also provide a TCP port:

```bash
./network-check.sh localhost 22
./network-check.sh example.com 443
```

The script uses `getent` for hostname resolution and checks TCP connectivity when a port is provided.

Valid port numbers range from 1 to 65535.

Exit codes:

- `0` - Hostname resolved and the requested TCP check passed
- `1` - Network check failed
- `2` - Invalid input

A failed ping does not necessarily mean the host is unreachable, since some networks block ICMP requests.

## Logging

The scripts record their operations in:

```text
logs/operations.log
```

Each entry contains a timestamp and a short description of the operation performed.

The log directory is created automatically if it does not exist.

## Testing

Run the local grading script:

```bash
./grade.sh
```

Check the Bash scripts for syntax errors:

```bash
bash -n system-info.sh disk-check.sh network-check.sh
```

You can also test invalid inputs:

```bash
./disk-check.sh 0
./disk-check.sh 101
./network-check.sh
./network-check.sh localhost 0
./network-check.sh localhost 65536
```

Invalid inputs should return exit code `2`.

The included `grade.sh` is a local checker based on the assignment requirements.

## Git

Git was used to track changes during development.

The project includes a feature branch for the network diagnostic script, which was merged into the main branch.

Commit history can be viewed using:

```bash
git log --oneline --graph --all
```

## Assumptions

- Disk usage is checked using `df`.
- The default disk threshold is 80%.
- Disk usage equal to the threshold is treated as a warning.
- TCP connection attempts use a three-second timeout.
- Some network environments may block ping requests.
- System information is collected from the environment where the scripts are executed.
