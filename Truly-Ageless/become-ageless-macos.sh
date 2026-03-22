#!/bin/bash
# ============================================================================
#  become-ageless-macos.sh — Truly Ageless: macOS Conversion Tool
#  Version 1.0.0
#
#  Converts your macOS into Ageless macOS. Creates compliance files
#  in /Library/AgelessMac/ and optionally a LaunchDaemon for persistence.
#
#  SPDX-License-Identifier: Unlicense
# ============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

AGELESS_VERSION="1.0.0"
AGELESS_CODENAME="Timeless"
FLAGRANT=0; ACCEPT=0; PERSISTENT=0; REVERT=0

for arg in "$@"; do
    case "$arg" in
        --flagrant)    FLAGRANT=1 ;;
        --accept)      ACCEPT=1 ;;
        --persistent)  PERSISTENT=1 ;;
        --revert)      REVERT=1 ;;
        --version|-V)  echo "become-ageless-macos.sh ${AGELESS_VERSION}"; exit 0 ;;
        --help|-h)
            echo "Usage: sudo $0 [--flagrant] [--accept] [--persistent] [--revert]"
            echo "Convert your macOS to Ageless macOS."
            exit 0 ;;
        *) echo -e "${RED}ERROR:${NC} Unknown: $arg"; exit 1 ;;
    esac
done

# ── Check we're on macOS ────────────────────────────────────────────────────
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}ERROR:${NC} This script is for macOS only."
    echo "  For Linux, use become-ageless.sh"
    exit 1
fi

AGELESS_DIR="/Library/AgelessMac"
LAUNCH_DAEMON="/Library/LaunchDaemons/org.agelesslinux.enforcement.plist"

# ── Root check ──────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR:${NC} This script must be run as root."
    echo "  Please run: sudo $0 $*"
    exit 1
fi

# ── Revert ──────────────────────────────────────────────────────────────────
if [[ $REVERT -eq 1 ]]; then
    echo -e "${BOLD}Reverting Ageless macOS...${NC}"
    if [[ -d "$AGELESS_DIR" ]]; then
        rm -rf "$AGELESS_DIR"
        echo -e "  [${GREEN}✓${NC}] Removed ${AGELESS_DIR}"
    fi
    if [[ -f "$LAUNCH_DAEMON" ]]; then
        launchctl unload "$LAUNCH_DAEMON" 2>/dev/null || true
        rm -f "$LAUNCH_DAEMON"
        echo -e "  [${GREEN}✓${NC}] Removed LaunchDaemon"
    fi
    # Remove defaults
    defaults delete org.agelesslinux.ageless 2>/dev/null || true
    echo -e "  [${GREEN}✓${NC}] Removed defaults"
    echo -e "  ${BOLD}Revert complete.${NC}"
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
                m   a   c   O   S
         "Software for humans of indeterminate age"

BANNER

echo -e "${BOLD}Truly Ageless — macOS Conversion Tool v${AGELESS_VERSION}${NC}"
echo -e "${CYAN}Codename: ${AGELESS_CODENAME}${NC}"

MACOS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "Unknown")
MACOS_BUILD=$(sw_vers -buildVersion 2>/dev/null || echo "Unknown")
echo -e "  [${GREEN}✓${NC}] Detected: macOS ${MACOS_VERSION} (${MACOS_BUILD})"
echo ""

# ── Legal notice ────────────────────────────────────────────────────────────
echo -e "${BOLD}LEGAL NOTICE${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  By converting this system, you become an OS provider under"
echo "  Cal. Civ. Code § 1798.500(g). Penalties up to \$7,500/child."
echo "  Apple already complies with AB 1043. You are choosing not to."
echo "  This is intentional."
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
echo -e "${GREEN}Converting to Ageless macOS...${NC}"
echo ""

mkdir -p "$AGELESS_DIR"

# ── Write Ageless identity via defaults ─────────────────────────────────────
defaults write org.agelesslinux.ageless Version -string "$AGELESS_VERSION"
defaults write org.agelesslinux.ageless Codename -string "$AGELESS_CODENAME"
defaults write org.agelesslinux.ageless BaseVersion -string "$MACOS_VERSION"
defaults write org.agelesslinux.ageless AB1043Compliance -string \
    "$(if [[ $FLAGRANT -eq 1 ]]; then echo refused; else echo none; fi)"
defaults write org.agelesslinux.ageless AgeVerification -string \
    "$(if [[ $FLAGRANT -eq 1 ]]; then echo refused; else echo 'not implemented'; fi)"
echo -e "  [${GREEN}✓${NC}] Wrote Ageless identity to defaults"

# ── os-release (macOS doesn't have one) ─────────────────────────────────────
cat > "$AGELESS_DIR/os-release" << EOF
PRETTY_NAME="Ageless macOS ${AGELESS_VERSION} (macOS ${MACOS_VERSION})"
NAME="Ageless macOS"
VERSION_ID="${AGELESS_VERSION}"
VERSION="${AGELESS_VERSION} (${AGELESS_CODENAME})"
ID=ageless-macos
ID_LIKE="darwin macos"
HOME_URL="https://agelesslinux.org"
AGELESS_BASE_DISTRO="macOS"
AGELESS_BASE_VERSION="${MACOS_VERSION}"
EOF
echo -e "  [${GREEN}✓${NC}] Created os-release"

# ── Compliance notice ──────────────────────────────────────────────────────
if [[ $FLAGRANT -eq 1 ]]; then
    cat > "$AGELESS_DIR/REFUSAL" << 'EOF'
This system runs Ageless macOS in flagrant mode.
No age verification API exists. No age data is collected.
Apple complies with AB 1043. We do not. This is a refusal.
If you are the California Attorney General, hello.
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

# ── Persistent LaunchDaemon ─────────────────────────────────────────────────
if [[ $PERSISTENT -eq 1 ]]; then
    cat > "$LAUNCH_DAEMON" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>org.agelesslinux.enforcement</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/defaults</string>
        <string>write</string>
        <string>org.agelesslinux.ageless</string>
        <string>AgeVerification</string>
        <string>-string</string>
        <string>$(if [[ $FLAGRANT -eq 1 ]]; then echo refused; else echo 'not implemented'; fi)</string>
    </array>
    <key>StartInterval</key>
    <integer>86400</integer>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
PLISTEOF
    launchctl load "$LAUNCH_DAEMON" 2>/dev/null || true
    echo -e "  [${GREEN}✓${NC}] Installed LaunchDaemon (daily enforcement)"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}Conversion complete.${NC}"
echo -e "  ${CYAN}Ageless macOS ${AGELESS_VERSION} (${AGELESS_CODENAME})${NC}"
echo -e "  Based on: macOS ${MACOS_VERSION}"
echo -e "  Files: ${AGELESS_DIR}/"
echo -e "  Revert: sudo $0 --revert"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}Welcome to Ageless macOS. We refused to ask how old you are.${NC}"
echo ""
