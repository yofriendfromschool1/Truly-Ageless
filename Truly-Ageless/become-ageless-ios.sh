#!/bin/bash
# ============================================================================
#  become-ageless-ios.sh — Truly Ageless: iOS/iPadOS Conversion Tool
#  Version 1.0.0
#
#  Requires a jailbroken device with SSH access.
#  Creates Ageless identity and compliance files on iOS/iPadOS.
#
#  SPDX-License-Identifier: Unlicense
# ============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

AGELESS_VERSION="1.0.0"
AGELESS_CODENAME="Timeless"
FLAGRANT=0; ACCEPT=0; REVERT=0

for arg in "$@"; do
    case "$arg" in
        --flagrant)    FLAGRANT=1 ;;
        --accept)      ACCEPT=1 ;;
        --revert)      REVERT=1 ;;
        --version|-V)  echo "become-ageless-ios.sh ${AGELESS_VERSION}"; exit 0 ;;
        --help|-h)
            echo "Usage: $0 [--flagrant] [--accept] [--revert]"
            echo "Convert a jailbroken iOS device to Ageless iOS."
            exit 0 ;;
        *) echo -e "${RED}ERROR:${NC} Unknown: $arg"; exit 1 ;;
    esac
done

AGELESS_DIR="/var/mobile/ageless"
SYSVER="/System/Library/CoreServices/SystemVersion.plist"

# ── Check environment ───────────────────────────────────────────────────────
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}ERROR:${NC} This script must run on an iOS/iPadOS device."
    exit 1
fi

# Check for iOS/iPadOS specifically
if ! sw_vers -productName 2>/dev/null | grep -qi "iP\|iPhone\|iPad"; then
    # Could be macOS — check for mobile user
    if [[ ! -d /var/mobile ]]; then
        echo -e "${YELLOW}WARNING:${NC} This does not appear to be an iOS device."
        echo "  For macOS, use become-ageless-macos.sh"
        if [[ -t 0 ]]; then
            read -rp "  Continue anyway? [y/N] " c
            [[ ! "$c" =~ ^[Yy]$ ]] && exit 0
        else
            exit 1
        fi
    fi
fi

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR:${NC} Root required. Run as root via SSH on jailbroken device."
    exit 1
fi

# ── Revert ──────────────────────────────────────────────────────────────────
if [[ $REVERT -eq 1 ]]; then
    echo -e "${BOLD}Reverting Ageless iOS...${NC}"
    [[ -d "$AGELESS_DIR" ]] && rm -rf "$AGELESS_DIR" && echo -e "  [${GREEN}✓${NC}] Removed ${AGELESS_DIR}"
    if [[ -f "${SYSVER}.pre-ageless" ]]; then
        cp "${SYSVER}.pre-ageless" "$SYSVER"
        echo -e "  [${GREEN}✓${NC}] Restored SystemVersion.plist"
    fi
    echo -e "  ${BOLD}Revert complete.${NC}"; exit 0
fi

# ── Banner ──────────────────────────────────────────────────────────────────
cat << 'BANNER'

     █████╗  ██████╗ ███████╗██╗     ███████╗███████╗███████╗
    ██╔══██╗██╔════╝ ██╔════╝██║     ██╔════╝██╔════╝██╔════╝
    ███████║██║  ███╗█████╗  ██║     █████╗  ███████╗███████╗
    ██╔══██║██║   ██║██╔══╝  ██║     ██╔══╝  ╚════██║╚════██║
    ██║  ██║╚██████╔╝███████╗███████╗███████╗███████║███████║
    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝
            i   O   S   /   i   P   a   d   O   S
         "Software for humans of indeterminate age"

BANNER

echo -e "${BOLD}Truly Ageless — iOS Conversion Tool v${AGELESS_VERSION}${NC}"
echo -e "${CYAN}Codename: ${AGELESS_CODENAME}${NC}"

IOS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
DEVICE_MODEL=$(uname -m 2>/dev/null || echo "Unknown")
echo -e "  [${GREEN}✓${NC}] Detected: iOS ${IOS_VERSION} (${DEVICE_MODEL})"
echo ""

echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  ⚠  JAILBREAK REQUIRED${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "  This script requires a jailbroken iOS/iPadOS device."
echo "  Running this on a non-jailbroken device will fail."
echo "  Modifying system files may void warranty."
echo ""

# ── Legal notice ────────────────────────────────────────────────────────────
echo -e "${BOLD}LEGAL NOTICE${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  By converting this device, you become an OS provider under"
echo "  Cal. Civ. Code § 1798.500(g). Apple already complies."
echo "  You are choosing not to. Penalties up to \$7,500/child."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [[ $ACCEPT -eq 1 ]]; then
    echo -e "${YELLOW}--accept: terms accepted.${NC}"
elif [[ -t 0 ]]; then
    read -rp "Accept terms? [y/N] " a
    [[ ! "$a" =~ ^[Yy]$ ]] && echo "Cancelled." && exit 0
else
    echo -e "${RED}ERROR:${NC} Pass --accept for non-interactive."; exit 1
fi

echo ""
echo -e "${GREEN}Converting to Ageless iOS...${NC}"
echo ""

mkdir -p "$AGELESS_DIR"

# ── Backup SystemVersion.plist ──────────────────────────────────────────────
if [[ -f "$SYSVER" ]] && [[ ! -f "${SYSVER}.pre-ageless" ]]; then
    cp "$SYSVER" "${SYSVER}.pre-ageless"
    echo -e "  [${GREEN}✓${NC}] Backed up SystemVersion.plist"
fi

# ── os-release ──────────────────────────────────────────────────────────────
cat > "$AGELESS_DIR/os-release" << EOF
PRETTY_NAME="Ageless iOS ${AGELESS_VERSION} (iOS ${IOS_VERSION})"
NAME="Ageless iOS"
VERSION_ID="${AGELESS_VERSION}"
ID=ageless-ios
ID_LIKE="darwin ios"
HOME_URL="https://agelesslinux.org"
AGELESS_BASE_DISTRO="iOS"
AGELESS_BASE_VERSION="${IOS_VERSION}"
EOF
echo -e "  [${GREEN}✓${NC}] Created os-release"

# ── Compliance ──────────────────────────────────────────────────────────────
if [[ $FLAGRANT -eq 1 ]]; then
    cat > "$AGELESS_DIR/REFUSAL" << 'EOF'
This device runs Ageless iOS in flagrant mode.
No age verification API exists. No age data is collected.
Apple complies with AB 1043. We jailbroke that compliance.
If you are the CA Attorney General, hello.
EOF
    echo -e "  [${RED}✓${NC}] Installed REFUSAL"
else
    cat > "$AGELESS_DIR/age-verification-api.sh" << 'EOF'
#!/bin/bash
echo "ERROR: Age data not available. Have a nice day."
exit 1
EOF
    chmod +x "$AGELESS_DIR/age-verification-api.sh"
    echo -e "  [${GREEN}✓${NC}] Installed stub API"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}Conversion complete.${NC}"
echo -e "  ${CYAN}Ageless iOS ${AGELESS_VERSION} (${AGELESS_CODENAME})${NC}"
echo -e "  Based on: iOS ${IOS_VERSION}"
echo -e "  Files: ${AGELESS_DIR}/"
echo -e "  Revert: $0 --revert"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}Welcome to Ageless iOS. We jailbroke the age gate.${NC}"
echo ""
