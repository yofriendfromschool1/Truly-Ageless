# Ageless Linux — Fedora Fork

> *"Software for humans of indeterminate age"*

```
     █████╗  ██████╗ ███████╗██╗     ███████╗███████╗███████╗
    ██╔══██╗██╔════╝ ██╔════╝██║     ██╔════╝██╔════╝██╔════╝
    ███████║██║  ███╗█████╗  ██║     █████╗  ███████╗███████╗
    ██╔══██║██║   ██║██╔══╝  ██║     ██╔══╝  ╚════██║╚════██║
    ██║  ██║╚██████╔╝███████╗███████╗███████╗███████║███████║
    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝
                    L   I   N   U   X
```

## Fork Statement

This repository is a **Fedora Linux fork** of the original [Ageless Linux](https://agelesslinux.org) project.

| | |
|---|---|
| **Original project** | [Ageless Linux](https://agelesslinux.org) |
| **Original author** | \|VOID\| (rowlandkhd@gmail.com) |
| **Fork maintainer** | [DesignForFailure](https://github.com/DesignForFailure) |
| **Fork purpose** | Extend support to Fedora, RHEL, CentOS, Rocky Linux, and AlmaLinux |

The upstream project targets Debian/Ubuntu exclusively. This fork adds first-class support for RPM-based distributions while preserving full Debian/Ubuntu compatibility.

## What Is This?

Ageless Linux is a distribution conversion tool that transforms your existing Linux installation into "Ageless Linux" — an operating system that **intentionally does not comply** with California's [Digital Age Assurance Act](https://leginfo.legislature.ca.gov/faces/billNavClient.xhtml?bill_id=202320240AB1043) (AB 1043, Chapter 675, Statutes of 2025).

By running this script, you become an **"operating system provider"** as defined by [California Civil Code § 1798.500(g)](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?sectionNum=1798.500.&lawCode=CIV), because you now "control the operating system software on a general purpose computing device."

Ageless Linux then proceeds to provide **none** of the age verification infrastructure that AB 1043 requires of operating system providers, in deliberate and documented noncompliance.

## Supported Distributions

| Distribution | Family | Status |
|---|---|---|
| **Fedora** (all versions) | `fedora` | Fully supported |
| **RHEL** / CentOS Stream | `rhel` | Fully supported |
| **Rocky Linux** | `rhel` | Fully supported |
| **AlmaLinux** | `rhel` | Fully supported |
| **Oracle Linux** | `rhel` | Fully supported |
| **Debian** | `debian` | Fully supported |
| **Ubuntu** | `debian` | Fully supported |
| Other Linux | — | Supported with warning |

## Dependencies

**None.** This script requires only:

- **Bash** (version 4.0+, for `${var,,}` lowercase expansion)
- Standard coreutils: `grep`, `cut`, `cp`, `mkdir`, `chmod`, `cat`, `mktemp`, `mv`, `head`
- Root access (`sudo`)
- An interactive terminal (the script requires informed consent via interactive prompts)

No packages need to be installed. No network access is required.

## Usage

### Standard Mode

```bash
sudo ./become-ageless.sh
```

Standard mode installs a **stub age verification API** (`/etc/ageless/age-verification-api.sh`) that returns no data. This preserves the fig leaf of a "good faith effort" under § 1798.502(b).

### Flagrant Mode

```bash
sudo ./become-ageless.sh --flagrant
```

Flagrant mode removes the fig leaf entirely. **No API is installed.** No interface of any kind exists for age collection. The system actively declares, in machine-readable form, that it refuses to comply. This mode is intended for devices that will be physically handed to children.

### Other Options

```bash
sudo ./become-ageless.sh --help      # Show usage information
sudo ./become-ageless.sh --version   # Show version
```

Unknown arguments are rejected with an error to prevent accidental misconfiguration (e.g., a `--flgrant` typo silently running in standard mode).

## What It Does

1. **Backs up** your original `/etc/os-release` (and `/etc/lsb-release`, `/etc/system-release`, `/etc/redhat-release`, `/etc/fedora-release` if they exist)
2. **Rewrites** those files to identify the system as "Ageless Linux"
3. **Creates** `/etc/ageless/ab1043-compliance.txt` — a detailed (non)compliance statement
4. **Standard mode**: Installs `/etc/ageless/age-verification-api.sh` — a nonfunctional stub API
5. **Flagrant mode**: Installs `/etc/ageless/REFUSAL` — a machine-readable refusal notice instead

## Reverting

To restore your original operating system identity:

```bash
sudo cp /etc/os-release.pre-ageless /etc/os-release
```

On Fedora/RHEL systems, also restore any additional release files:

```bash
# Restore if backups exist
[ -f /etc/system-release.pre-ageless ] && sudo cp /etc/system-release.pre-ageless /etc/system-release
[ -f /etc/redhat-release.pre-ageless ] && sudo cp /etc/redhat-release.pre-ageless /etc/redhat-release
[ -f /etc/fedora-release.pre-ageless ] && sudo cp /etc/fedora-release.pre-ageless /etc/fedora-release
[ -f /etc/lsb-release.pre-ageless ]   && sudo cp /etc/lsb-release.pre-ageless /etc/lsb-release
```

## Files Created

| File | Description |
|---|---|
| `/etc/os-release` | Rewritten OS identity |
| `/etc/os-release.pre-ageless` | Backup of original OS identity |
| `/etc/system-release.pre-ageless` | Backup (Fedora/RHEL only, if original exists) |
| `/etc/redhat-release.pre-ageless` | Backup (RHEL family only, if original exists) |
| `/etc/fedora-release.pre-ageless` | Backup (Fedora only, if original exists) |
| `/etc/ageless/ab1043-compliance.txt` | (Non)compliance statement |
| `/etc/ageless/age-verification-api.sh` | Nonfunctional stub API (standard mode) |
| `/etc/ageless/REFUSAL` | Machine-readable refusal (flagrant mode) |

## Security Considerations

This script runs as root and modifies system identity files. The following safeguards are in place:

- **`umask 022`** is set before creating any files, ensuring files in `/etc/` are never world-writable regardless of the calling environment
- **Atomic file writes** — system files (`/etc/os-release`, release files) are written to a temp file first, then atomically renamed via `mv`, preventing corruption if interrupted mid-write
- **Signal trap** — if interrupted (Ctrl+C / SIGTERM) during conversion, the script warns the user about the inconsistent state and provides recovery instructions
- **Interactive terminal required** — the script refuses to run with piped/redirected stdin, ensuring the legal consent prompts cannot be bypassed
- **Strict argument parsing** — unknown flags are rejected with an error, preventing typos like `--flgrant` from silently running the wrong mode
- **Precise distro detection** — only the `ID=` and `ID_LIKE=` fields of `/etc/os-release` are matched, preventing false positives from URLs or descriptions containing distro names
- **Backup-before-modify** — original system files are backed up before any modifications, with clear restore instructions

**Note:** This script intentionally modifies `/etc/os-release` and related system identity files. This may affect package managers, monitoring tools, and cloud infrastructure agents that depend on accurate OS identification. Understand the implications before running on production systems.

## Legal Disclaimer

**By using this software, you acknowledge that:**

1. You may become an "operating system provider" under California Civil Code § 1798.500(g).
2. You may be subject to civil penalties under § 1798.503(a) of up to **$2,500 per affected child** per negligent violation, or **$7,500 per affected child** per intentional violation.
3. This software intentionally does not comply with the age verification requirements of AB 1043.
4. **This is not legal advice.** Consult an attorney before deploying this on systems subject to California jurisdiction.

## Legal References

- [AB 1043 — Digital Age Assurance Act (Full Text)](https://leginfo.legislature.ca.gov/faces/billNavClient.xhtml?bill_id=202320240AB1043)
- [California Civil Code § 1798.500–1798.503](https://leginfo.legislature.ca.gov/faces/codes_displaySection.xhtml?sectionNum=1798.500.&lawCode=CIV) — Definitions and requirements for OS providers
- [California AG Consumer Complaint Form](https://oag.ca.gov/contact/consumer-complaint-against-business-or-company) — For reporting noncompliance (including your own)

## License

This project is released into the **public domain** under the [Unlicense](LICENSE).

See [SPDX: Unlicense](https://spdx.org/licenses/Unlicense.html) for details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Links

- **Ageless Linux (upstream)**: [https://agelesslinux.org](https://agelesslinux.org)
- **This fork**: [https://github.com/DesignForFailure/Ageless-Fedora-Linux-Fork](https://github.com/DesignForFailure/Ageless-Fedora-Linux-Fork)
- **Issue tracker**: [https://github.com/DesignForFailure/Ageless-Fedora-Linux-Fork/issues](https://github.com/DesignForFailure/Ageless-Fedora-Linux-Fork/issues)
