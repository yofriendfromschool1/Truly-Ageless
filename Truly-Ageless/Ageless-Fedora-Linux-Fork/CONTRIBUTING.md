# Contributing to Ageless Linux (Fedora Fork)

Thank you for your interest in contributing to this project.

## How to Contribute

1. **Fork** this repository.
2. **Create a branch** for your changes (`git checkout -b my-feature`).
3. **Make your changes** and test them on a Fedora or RHEL-based system.
4. **Commit** with a clear, descriptive message.
5. **Open a pull request** against the `main` branch.

## Guidelines

- This is a single-file Bash project. Keep it that way unless there is a compelling reason to add files.
- All changes must work on Fedora, RHEL, CentOS, Rocky Linux, and AlmaLinux. Debian/Ubuntu compatibility should also be preserved.
- Test with `bash -n become-ageless.sh` (syntax check) before submitting.
- Follow the existing code style: `set -euo pipefail`, consistent indentation, and clear section headers.
- Do not introduce external dependencies. The script must run with only standard coreutils.

## Reporting Issues

Open an issue on the [GitHub issue tracker](https://github.com/DesignForFailure/Ageless-Fedora-Linux-Fork/issues). Include:

- Your distribution and version (`cat /etc/os-release`)
- The exact command you ran
- The full error output

## Legal

By contributing to this project, you agree that your contributions are released under the [Unlicense](LICENSE) (public domain).

## Upstream

This is a fork. If your contribution applies to the upstream (Debian-only) project, consider contributing there as well: [https://agelesslinux.org](https://agelesslinux.org)
