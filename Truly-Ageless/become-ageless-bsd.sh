#!/bin/sh
# ============================================================================
#  become-ageless-bsd.sh — Truly Ageless: BSD Conversion Tool
#  Version 1.0.0
#
#  Supports FreeBSD, OpenBSD, NetBSD, and DragonFlyBSD.
#  Uses /bin/sh for maximum portability across BSD variants.
#
#  SPDX-License-Identifier: Unlicense
# ============================================================================

set -eu

AGELESS_VERSION="1.0.0"
AGELESS_CODENAME="Timeless"
FLAGRANT=0; ACCEPT=0; PERSISTENT=0; REVERT=0

# Colors (may not work on all BSD consoles)
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ── Argument parsing ────────────────────────────────────────────────────────
for arg in "$@"; do
    case "$arg" in
        --flagrant)    FLAGRANT=1 ;;
        --accept)      ACCEPT=1 ;;
        --persistent)  PERSISTENT=1 ;;
        --revert)      REVERT=1 ;;
        --version|-V)  echo "become-ageless-bsd.sh ${AGELESS_VERSION}"; exit 0 ;;
        --help|-h)
            echo "Usage: sudo $0 [--flagrant] [--accept] [--persistent] [--revert]"
            echo "Convert your BSD system to Ageless BSD."
            echo "Supports FreeBSD, OpenBSD, NetBSD, DragonFlyBSD."
            exit 0 ;;
        *) printf "${RED}ERROR:${NC} Unknown: %s\n" "$arg"; exit 1 ;;
    esac
done

# ── Detect BSD variant ──────────────────────────────────────────────────────
BSD_TYPE=$(uname -s)
case "$BSD_TYPE" in
    FreeBSD)     BSD_FAMILY="freebsd" ;;
    OpenBSD)     BSD_FAMILY="openbsd" ;;
    NetBSD)      BSD_FAMILY="netbsd" ;;
    DragonFly)   BSD_FAMILY="dragonfly" ;;
    *)
        printf "${RED}ERROR:${NC} Unsupported system: %s\n" "$BSD_TYPE"
        echo "  For Linux, use become-ageless.sh"
        exit 1
        ;;
esac

BSD_VERSION=$(uname -r)
AGELESS_DIR="/etc/ageless"

# ── Root check ──────────────────────────────────────────────────────────────
if [ "$(id -u)" -ne 0 ]; then
    printf "${RED}ERROR:${NC} Must be run as root. Use: sudo %s\n" "$0"
    exit 1
fi

# ── Revert ──────────────────────────────────────────────────────────────────
if [ "$REVERT" -eq 1 ]; then
    printf "${BOLD}Reverting Ageless BSD...${NC}\n"
    if [ -d "$AGELESS_DIR" ]; then
        rm -rf "$AGELESS_DIR"
        printf "  [${GREEN}✓${NC}] Removed %s\n" "$AGELESS_DIR"
    fi
    if [ -f /etc/motd.pre-ageless ]; then
        cp /etc/motd.pre-ageless /etc/motd
        printf "  [${GREEN}✓${NC}] Restored /etc/motd\n"
    fi
    # Remove cron job
    crontab -l 2>/dev/null | grep -v "ageless-enforce" | crontab - 2>/dev/null || true
    printf "  ${BOLD}Revert complete.${NC}\n"
    exit 0
fi

# ── Banner ──────────────────────────────────────────────────────────────────
cat << 'BANNER'

     █████╗  ██████╗ ███████╗██╗     ███████╗███████╗███████╗
    ██╔══██╗██╔════╝ ██╔════╝██║     ██╔════╝██╔════╝██╔════╝
    ███████║██║  ███╗█████╗  ██║     █████╗  ███████╗███████╗
    ██╔══██║██║   ██║██╔══╝  ██║     ██╔══╝  ╚════██║╚════██║
    ██║  ██║╚██████╔╝███████╗███████╗███████╗███████║███████║
    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝
                    B   S   D
         "Software for humans of indeterminate age"

BANNER

printf "${BOLD}Truly Ageless — BSD Conversion Tool v${AGELESS_VERSION}${NC}\n"
printf "${CYAN}Codename: ${AGELESS_CODENAME}${NC}\n"
printf "  [${GREEN}✓${NC}] Detected: %s %s\n" "$BSD_TYPE" "$BSD_VERSION"
echo ""

# ── Legal notice ────────────────────────────────────────────────────────────
printf "${BOLD}LEGAL NOTICE${NC}\n"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  By converting this system, you become an OS provider under"
echo "  Cal. Civ. Code § 1798.500(g). Penalties up to \$7,500/child."
echo "  BSD cannot comply. Neither can we. This is intentional."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$ACCEPT" -eq 1 ]; then
    printf "${YELLOW}--accept: terms accepted.${NC}\n"
elif [ -t 0 ]; then
    printf "Accept terms? [y/N] "
    read a
    case "$a" in
        [Yy]*) ;;
        *) echo "Cancelled."; exit 0 ;;
    esac
else
    printf "${RED}ERROR:${NC} Pass --accept for non-interactive.\n"; exit 1
fi

echo ""
printf "${GREEN}Converting to Ageless BSD...${NC}\n"
echo ""

mkdir -p "$AGELESS_DIR"

# ── os-release (BSDs don't have one natively) ───────────────────────────────
cat > "$AGELESS_DIR/os-release" << EOF
PRETTY_NAME="Ageless BSD ${AGELESS_VERSION} (${BSD_TYPE} ${BSD_VERSION})"
NAME="Ageless BSD"
VERSION_ID="${AGELESS_VERSION}"
VERSION="${AGELESS_VERSION} (${AGELESS_CODENAME})"
ID=ageless-bsd
ID_LIKE="${BSD_FAMILY}"
HOME_URL="https://agelesslinux.org"
AGELESS_BASE_DISTRO="${BSD_TYPE}"
AGELESS_BASE_VERSION="${BSD_VERSION}"
EOF
printf "  [${GREEN}✓${NC}] Created os-release\n"

# ── Modify /etc/motd ────────────────────────────────────────────────────────
if [ -f /etc/motd ] && [ ! -f /etc/motd.pre-ageless ]; then
    cp /etc/motd /etc/motd.pre-ageless
fi
cat > /etc/motd << MOTDEOF

  ═══════════════════════════════════════════════════════════════
  This system runs Ageless BSD ${AGELESS_VERSION} (${AGELESS_CODENAME})
  Based on: ${BSD_TYPE} ${BSD_VERSION}

  This operating system provider does not comply with
  California's Digital Age Assurance Act (AB 1043).
  We do not know how old you are. We do not want to know.

  https://agelesslinux.org
  ═══════════════════════════════════════════════════════════════

MOTDEOF
printf "  [${GREEN}✓${NC}] Updated /etc/motd\n"

# ── Compliance / REFUSAL ────────────────────────────────────────────────────
if [ "$FLAGRANT" -eq 1 ]; then
    cat > "$AGELESS_DIR/REFUSAL" << 'EOF'
This system runs Ageless BSD in flagrant mode.
No age verification API exists. No age data is collected.
BSD cannot comply with AB 1043. We won't even pretend.
If you are the California Attorney General, hello.
EOF
    printf "  [${RED}✓${NC}] Installed REFUSAL\n"
else
    cat > "$AGELESS_DIR/age-verification-api.sh" << 'EOF'
#!/bin/sh
echo "ERROR: Age data not available. Have a nice day."
exit 1
EOF
    chmod +x "$AGELESS_DIR/age-verification-api.sh"
    printf "  [${GREEN}✓${NC}] Installed stub API\n"
fi

# ── Persistent cron (if requested) ──────────────────────────────────────────
if [ "$PERSISTENT" -eq 1 ]; then
    # Create enforcement script
    cat > "$AGELESS_DIR/ageless-enforce.sh" << 'ENFORCE_EOF'
#!/bin/sh
# Ageless BSD enforcement — ensures compliance files persist
AGELESS_DIR="/etc/ageless"
[ -d "$AGELESS_DIR" ] || mkdir -p "$AGELESS_DIR"
[ -f "$AGELESS_DIR/os-release" ] || echo "NAME=\"Ageless BSD\"" > "$AGELESS_DIR/os-release"
ENFORCE_EOF
    chmod +x "$AGELESS_DIR/ageless-enforce.sh"

    # Add daily cron
    (crontab -l 2>/dev/null; echo "0 3 * * * /etc/ageless/ageless-enforce.sh # ageless-enforce") | sort -u | crontab -
    printf "  [${GREEN}✓${NC}] Installed daily cron job\n"
fi

# ── FreeBSD-specific: rc.conf ───────────────────────────────────────────────
if [ "$BSD_FAMILY" = "freebsd" ]; then
    if ! grep -q "ageless" /etc/rc.conf 2>/dev/null; then
        echo '# Ageless BSD identity' >> /etc/rc.conf
        echo 'ageless_enable="YES"' >> /etc/rc.conf
        printf "  [${GREEN}✓${NC}] Updated /etc/rc.conf\n"
    fi
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
printf "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "  ${BOLD}Conversion complete.${NC}\n"
printf "  ${CYAN}Ageless BSD ${AGELESS_VERSION} (${AGELESS_CODENAME})${NC}\n"
printf "  Based on: %s %s\n" "$BSD_TYPE" "$BSD_VERSION"
printf "  Files: %s/\n" "$AGELESS_DIR"
printf "  Revert: sudo %s --revert\n" "$0"
printf "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
printf "  ${BOLD}Welcome to Ageless BSD. We refused to ask how old you are.${NC}\n"
echo ""
