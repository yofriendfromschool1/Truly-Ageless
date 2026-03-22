# Truly Ageless

> *"Software for humans of indeterminate age"*

```
     █████╗  ██████╗ ███████╗██╗     ███████╗███████╗███████╗
    ██╔══██╗██╔════╝ ██╔════╝██║     ██╔════╝██╔════╝██╔════╝
    ███████║██║  ███╗█████╗  ██║     █████╗  ███████╗███████╗
    ██╔══██║██║   ██║██╔══╝  ██║     ██╔══╝  ╚════██║╚════██║
    ██║  ██║╚██████╔╝███████╗███████╗███████╗███████║███████║
    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝
```

[![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)](LICENSE)

**Truly Ageless** is a multi-platform operating system conversion toolkit that transforms your device — Linux, Windows, macOS, Android, iOS, or BSD — into an **Ageless** system: one that intentionally, knowingly, and flagrantly refuses to comply with California's [Digital Age Assurance Act](https://leginfo.legislature.ca.gov/faces/billNavClient.xhtml?bill_id=202320240AB1043) (AB 1043).

We don't know how old you are. We don't want to know. We are legally required to ask. **We won't.**

---

## What Is This?

California AB 1043 requires every **operating system provider** to:

1. Collect the age or birthdate of every user at account setup
2. Provide a real-time API so applications can request age bracket signals
3. Comply or face fines of **$2,500–$7,500 per affected child**

Apple, Google, and Microsoft can comply — they already have the infrastructure. The 600+ volunteer-maintained Linux distributions, BSD projects, and hobbyist OSes **cannot**, because complying would require building surveillance infrastructure that fundamentally contradicts their reason for existing.

**Truly Ageless** exists because someone should say no. By running any of our conversion scripts, you become an "operating system provider" under [Cal. Civ. Code § 1798.500(g)](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?sectionNum=1798.500.&lawCode=CIV) — and then you proceed to provide **none** of the required age verification infrastructure.

This is not a bug. This is a policy decision.

---

## Platform Support

| Platform | Script | Requires | Status |
|----------|--------|----------|--------|
| **All Linux** (Debian, Fedora, Arch, openSUSE, Void, Alpine, NixOS, Gentoo, Slackware, etc.) | `become-ageless.sh` | Root | ✅ Full support |
| **Windows** (10, 11, Server) | `Ageless-Windows/become-ageless.ps1` | Administrator | ✅ Full support |
| **Android** (Termux or rooted) | `become-ageless-android.sh` | None / Root | ✅ Full support |
| **macOS** (10.15+) | `become-ageless-macos.sh` | Root | ✅ Full support |
| **iOS / iPadOS** (jailbroken) | `become-ageless-ios.sh` | Jailbreak + Root | ⚠️ Requires jailbreak |
| **BSD** (FreeBSD, OpenBSD, NetBSD, DragonFlyBSD) | `become-ageless-bsd.sh` | Root | ✅ Full support |

---

## Quick Start

### Linux (All Distributions)

```bash
# Interactive
sudo ./become-ageless.sh

# Non-interactive
sudo ./become-ageless.sh --accept

# Flagrant mode (intended for devices handed to children)
sudo ./become-ageless.sh --accept --flagrant

# With persistent daemon (24h enforcement)
sudo ./become-ageless.sh --accept --persistent

# Remote install
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/Truly-Ageless/main/become-ageless.sh | sudo bash -s -- --accept

# Revert everything
sudo ./become-ageless.sh --revert
```

### Windows

```powershell
# Interactive (run as Administrator)
.\Ageless-Windows\become-ageless.ps1

# Non-interactive
.\Ageless-Windows\become-ageless.ps1 -Accept

# Flagrant mode
.\Ageless-Windows\become-ageless.ps1 -Accept -Flagrant

# With daily scheduled task
.\Ageless-Windows\become-ageless.ps1 -Accept -Persistent

# Revert
.\Ageless-Windows\become-ageless.ps1 -Revert
```

### Android (Termux)

```bash
# Install in Termux (no root needed)
./become-ageless-android.sh --accept

# With root
su -c './become-ageless-android.sh --accept --flagrant'
```

### macOS

```bash
sudo ./become-ageless-macos.sh --accept
sudo ./become-ageless-macos.sh --accept --persistent  # with LaunchDaemon
```

### iOS (Jailbroken)

```bash
# Via SSH on jailbroken device
ssh root@device './become-ageless-ios.sh --accept'
```

### BSD

```bash
sudo ./become-ageless-bsd.sh --accept
sudo ./become-ageless-bsd.sh --accept --persistent  # with cron
```

---

## CLI Reference

### Linux: `become-ageless.sh`

| Flag | Description |
|------|-------------|
| `--flagrant` | Remove all compliance fig leaves. No API installed. REFUSAL notice only. |
| `--accept` | Accept legal terms non-interactively |
| `--persistent` | Install `agelessd` systemd timer (24h birthDate enforcement) |
| `--revert` | Revert to original OS identity and remove all Ageless files |
| `--help` | Show usage |
| `--version` | Show version |

### Windows: `become-ageless.ps1`

| Flag | Description |
|------|-------------|
| `-Flagrant` | Explicit refusal mode |
| `-Accept` | Non-interactive |
| `-Persistent` | Install daily scheduled task |
| `-Revert` | Full revert (registry, files, scheduled task) |
| `-Help` | Show usage |
| `-Version` | Show version |

### All Other Platforms

All scripts support: `--flagrant`, `--accept`, `--revert`, `--help`, `--version`. macOS and BSD also support `--persistent`.

---

## What Each Script Modifies

### Linux

| File | Purpose |
|------|---------|
| `/etc/os-release` | Rewritten to identify as Ageless Linux |
| `/etc/os-release.pre-ageless` | Backup of original |
| `/etc/lsb-release` | Updated (if exists) |
| `/etc/{system,redhat,fedora}-release` | Updated (if exist) |
| `/etc/ageless/ab1043-compliance.txt` | Compliance statement |
| `/etc/ageless/age-verification-api.sh` | Nonfunctional stub API (standard mode) |
| `/etc/ageless/REFUSAL` | Machine-readable refusal (flagrant mode) |
| `/etc/userdb/*.user` | systemd userdb birthDate neutralization |
| `/etc/ageless/agelessd` | Neutralization daemon (persistent mode) |

### Windows

| Location | Purpose |
|----------|---------|
| `HKLM:\SOFTWARE\AgelessWindows` | Ageless identity registry keys |
| `HKLM:\...\OEMInformation` | OEM branding (backed up first) |
| `%ProgramData%\AgelessWindows\` | Compliance files, backup, revert script |
| `AgelessEnforcement` scheduled task | Daily enforcement (persistent mode) |

### macOS

| File | Purpose |
|------|---------|
| `/Library/AgelessMac/` | Compliance files and os-release |
| `org.agelesslinux.ageless` defaults | Identity via `defaults write` |
| LaunchDaemon | Daily enforcement (persistent mode) |

### Android

| File | Purpose |
|------|---------|
| `$PREFIX/etc/ageless/` (Termux) | Sandboxed compliance files |
| `/data/local/tmp/ageless/` (root) | System-level compliance files |
| System properties | `persist.ageless.*` (root only) |

### BSD

| File | Purpose |
|------|---------|
| `/etc/ageless/` | Compliance files and os-release |
| `/etc/motd` | Login message with Ageless identity |
| `/etc/rc.conf` | FreeBSD branding (FreeBSD only) |
| Cron job | Daily enforcement (persistent mode) |

---

## Modes of Operation

### Standard Mode

Installs a **stub age verification API** — a script that returns no data. This preserves the thin argument for a "good faith effort" under § 1798.502(b).

### Flagrant Mode (`--flagrant` / `-Flagrant`)

Removes the fig leaf entirely. **No API is installed.** Instead, a `REFUSAL` file is placed on the system declaring, in plain text, that this operating system provider declines to comply and invites enforcement action. This mode is intended for devices that will be physically placed into a child's hands.

### Persistent Mode (`--persistent` / `-Persistent`)

Installs a recurring enforcement mechanism (systemd timer on Linux, scheduled task on Windows, LaunchDaemon on macOS, cron on BSD) that ensures Ageless identity persists across system updates, user creation, and reboot.

---

## Existing Forks (Included)

This repository consolidates and preserves the following community forks:

| Directory | Description | Original |
|-----------|-------------|----------|
| `Ageless-Linux-fork-/` | Original Debian-only fork | [GitHub](https://github.com/agelesslinux/ageless-linux) |
| `Ageless-Fedora-Linux-Fork/` | Fedora/RHEL fork with atomic writes | [DesignForFailure](https://github.com/DesignForFailure/Ageless-Fedora-Linux-Fork) |
| `Ageless-Windows/` | Windows PowerShell conversion | Community |
| `ageless-arch-filesystem/` | Arch Linux filesystem PKGBUILD | Community |
| `ageless-fedora/` | Fedora fork documentation | [dovezp](https://github.com/dovezp/ageless-fedora) |
| `agelesslinux.org/` | Original website source | [agelesslinux.org](https://agelesslinux.org) |

The root-level scripts (`become-ageless.sh`, `become-ageless-*.sh`) are the unified, improved versions that supersede these individual forks.

---

## Legal Notice

**By using this software, you acknowledge that:**

1. You may become an "operating system provider" under [California Civil Code § 1798.500(g)](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?sectionNum=1798.500.&lawCode=CIV).
2. You may be subject to civil penalties under § 1798.503(a) of up to **$2,500 per affected child** per negligent violation, or **$7,500 per affected child** per intentional violation.
3. This software intentionally does not comply with the age verification requirements of AB 1043.
4. **This is intentional.** Ageless Linux is designed to violate AB 1043 as a form of civil disobedience against age verification mandates that function as compliance moats protecting incumbent tech monopolies.
5. **This is not legal advice.** Consult an attorney before deploying on systems subject to California jurisdiction.

---

## Why We Built This

> *AB 1043 passed the California Assembly 76–0 and the Senate 38–0. Not a single legislator voted against it. The bill had the explicit support of Apple, Google, and the major platform companies. Ask yourself why.*

A law that the largest companies in the world already comply with, and that hundreds of small projects cannot comply with, is not a child safety law. It is a compliance moat. The scholarship agrees:

- The **EFF** [calls age gates](https://www.eff.org/) "a windfall for Big Tech and a death sentence for smaller platforms"
- Legal scholar **Eric Goldman**'s "segregate-and-suppress" analysis describes exactly the architecture AB 1043 creates
- Cryptographer **Steven Bellovin** has demonstrated that no privacy-preserving age verification system can work as promised
- The **Center for Democracy & Technology** confirms teens view age verification as trivially bypassable and privacy-invasive

We didn't invent these arguments. We just built the bash script.

---

## Contributing

Contributions welcome. If you'd like to add support for a new platform, improve an existing script, or translate the compliance notices into additional languages:

1. Fork this repository
2. Create a feature branch
3. Submit a pull request

Please maintain the tone and spirit of the project. We are serious about civil disobedience. We are not serious about taking ourselves seriously.

---

## License

This project is released into the **public domain** under the [Unlicense](LICENSE).

You can copy it, modify it, distribute it, sell it, burn it, print it on USB drive labels, or hand it to a child at a school STEM fair. No permission needed. No attribution required. No warranty provided.

`SPDX-License-Identifier: Unlicense`

---

## References

- [AB 1043 — Digital Age Assurance Act (Full Text)](https://leginfo.legislature.ca.gov/faces/billNavClient.xhtml?bill_id=202320240AB1043)
- [Cal. Civ. Code § 1798.500–1798.503](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?sectionNum=1798.500.&lawCode=CIV)
- [Ageless Linux (upstream project)](https://agelesslinux.org)
- [systemd PR #40954 — birthDate field](https://github.com/systemd/systemd/pull/40954)
- [CA AG Consumer Complaint Form](https://oag.ca.gov/contact/consumer-complaint-against-business-or-company) — for reporting noncompliance (including your own)

---

**Welcome to Truly Ageless.** We refused to ask how old you are.
