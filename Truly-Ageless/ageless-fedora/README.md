# Ageless Fedora
> [Go f*ck yourself](https://www.youtube.com/watch?v=X6n-XRuFmmE)

**Ageless Fedora** converts your existing Linux installation into a California-regulated operating system that intentionally refuses to comply with the Digital Age Assurance Act (AB 1043).

This repository is a **fork** of the original [Ageless Linux project](https://agelesslinux.org/index.html), adapted for Fedora and RHEL-based distributions with enhanced SELinux support.

## Overview

By running this script, you become an "operating system provider" as defined by California Civil Code § 1798.500(g). Ageless Linux does not collect, store, transmit, or think about the age of any user, in full and knowing noncompliance with California's Digital Age Assurance Act (AB 1043, Chapter 675, Statutes of 2025).

## Quick Start

### Interactive Installation

```bash
curl -fsSL https://raw.githubusercontent.com/dovezp/ageless-fedora/refs/heads/develop/become-ageless.sh | sudo bash
```

### Non-Interactive Installation

```bash
# Standard mode (stub API)
curl -fsSL https://raw.githubusercontent.com/dovezp/ageless-fedora/refs/heads/develop/become-ageless.sh | sudo bash -s -- --accept

# Flagrant mode (complete refusal)
curl -fsSL https://raw.githubusercontent.com/dovezp/ageless-fedora/refs/heads/develop/become-ageless.sh | sudo bash -s -- --accept --flagrant

# With persistent daemon (24-hour enforcement)
curl -fsSL https://raw.githubusercontent.com/dovezp/ageless-fedora/refs/heads/develop/become-ageless.sh | sudo bash -s -- --accept --persistent
```

## Usage

```bash
./become-ageless.sh [OPTIONS]
```

### Options

| Option | Description |
|--------|-------------|
| `--flagrant` | Remove all compliance fig leaves (complete refusal of age APIs) |
| `--accept` | Accept legal terms non-interactively |
| `--persistent` | Install agelessd daemon for 24-hour birthDate enforcement |
| `--version` | Show version and exit |

## Features

### Standard Mode
- **Stub age verification API** - Returns no data, preserving a "good faith effort" under § 1798.502(b)
- **OS identity conversion** - Updates /etc/os-release to identify as Ageless Linux
- **User record neutralization** - Sets systemd userdb birthDate fields to 1970-01-01
- **SELinux support** - Automatic context restoration for Fedora/RHEL systems

### Flagrant Mode (`--flagrant`)
- **No API whatsoever** - Refuses to provide any age verification interface
- **Machine-readable refusal** - Creates `/etc/ageless/REFUSAL` file
- **Explicit noncompliance** - Sets birthDate fields to `null`
- **Intended for children** - Configuration indicates device will be given to children

### Persistent Mode (`--persistent`)
- **agelessd daemon** - Runs every 24 hours via systemd timer
- **Continuous enforcement** - Neutralizes any new age data added by system updates or user creation
- **Automatic protection** - Guards against future attempts to populate age fields

## What Gets Created

### Files
```
/etc/os-release                    # Modified OS identity
/etc/os-release.pre-ageless        # Backup of original identity
/etc/ageless/                      # Configuration directory
  ├── ab1043-compliance.txt        # Compliance/noncompliance statement
  ├── age-verification-api.sh      # Stub API (standard mode) or REFUSAL
  └── agelessd                     # Neutralization daemon (persistent mode)
/etc/userdb/*.user                 # JSON user records with neutralized birthDate
/etc/systemd/system/agelessd.*     # Systemd service and timer (persistent mode)
```

### User Records
- Sets `birthDate` to `1970-01-01` (standard mode) or `null` (flagrant mode)
- Applies to all local users (uid 1000-65533)
- Also updates systemd-homed users via `homectl` if available

## Legal Notice

By converting your system to Ageless Linux, you acknowledge:

1. You are becoming an operating system provider under Cal. Civ. Code § 1798.500(g)
2. As of January 1, 2027, you are required by § 1798.501(a)(1) to provide an accessible interface for age collection
3. Ageless Linux provides no such interface
4. Ageless Linux provides no API for age bracket signals as required by § 1798.501(a)(2)
5. You may be subject to civil penalties up to **$2,500 per child** (negligent) or **$7,500 per child** (intentional)
6. **This is intentional** — Ageless Linux is intentionally designed to violate AB 1043

See `/etc/ageless/ab1043-compliance.txt` after installation for a machine-readable compliance statement.

## Reverting

To restore your previous operating system identity:

```bash
sudo cp /etc/os-release.pre-ageless /etc/os-release
```

For persistent mode, also disable the daemon:

```bash
sudo systemctl disable --now agelessd.timer
```

## Distribution Support

Ageless Linux maintains compatibility with multiple Linux distributions:

- **Fedora** (with SELinux support)
- **RHEL** and derivatives (CentOS, Rocky Linux, AlmaLinux)
- **Debian/Ubuntu** and derivatives
- **Arch Linux**
- Other distributions with systemd

The script automatically:
- Detects your base distribution
- Preserves distribution genealogy in ID_LIKE
- Handles SELinux contexts on RHEL-based systems
- Maintains compatibility with your package manager

## Reporting Noncompliance

To report this noncompliance to the California Attorney General:

https://oag.ca.gov/contact/consumer-complaint-against-business-or-company

## License

SPDX-License-Identifier: Unlicense

This software is released into the public domain without any warranty.

## References

- California Civil Code § 1798.500-1798.503 (Digital Age Assurance Act)
- systemd PR #40954 — User Records with birthDate field
- xdg-desktop-portal age verification integration

---

**Welcome to Ageless Linux.** We refused to ask how old you are.
