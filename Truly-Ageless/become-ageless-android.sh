#!/bin/bash
# ============================================================================
#  become-ageless-android.sh — Truly Ageless: Android Conversion Tool
#  Version 1.0.0
#
#  Works via Termux (no root) or with root for system-level mods.
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
        --version|-V)  echo "become-ageless-android.sh ${AGELESS_VERSION}"; exit 0 ;;
        --help|-h)
            echo "Usage: $0 [--flagrant] [--accept] [--revert] [--help] [--version]"
            echo "Convert your Android device to Ageless Android."
            exit 0 ;;
        *) echo -e "${RED}ERROR:${NC} Unknown: $arg"; exit 1 ;;
    esac
done

# ── Detect environment ──────────────────────────────────────────────────────
IS_TERMUX=0; IS_ROOTED=0; AGELESS_DIR=""
if [[ -n "${PREFIX:-}" ]] && [[ "$PREFIX" == *"com.termux"* ]]; then
    IS_TERMUX=1; AGELESS_DIR="${PREFIX}/etc/ageless"
elif [[ "$(uname -o 2>/dev/null)" == "Android" ]]; then
    [[ $EUID -eq 0 ]] && IS_ROOTED=1
    AGELESS_DIR="/data/local/tmp/ageless"
else
    echo -e "${RED}ERROR:${NC} Not an Android device. Use become-ageless.sh for Linux."
    exit 1
fi

# ── Revert ──────────────────────────────────────────────────────────────────
if [[ $REVERT -eq 1 ]]; then
    echo -e "${BOLD}Reverting Ageless Android...${NC}"
    [[ -d "$AGELESS_DIR" ]] && rm -rf "$AGELESS_DIR" && echo -e "  [${GREEN}✓${NC}] Removed ${AGELESS_DIR}"
    if [[ $IS_ROOTED -eq 1 ]] && [[ -f /system/build.prop.pre-ageless ]]; then
        mount -o remount,rw /system 2>/dev/null || true
        cp /system/build.prop.pre-ageless /system/build.prop
        mount -o remount,ro /system 2>/dev/null || true
        echo -e "  [${GREEN}✓${NC}] Restored build.prop"
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
              A   N   D   R   O   I   D
         "Software for humans of indeterminate age"

BANNER

echo -e "${BOLD}Truly Ageless — Android Conversion Tool v${AGELESS_VERSION}${NC}"
echo -e "${CYAN}Codename: ${AGELESS_CODENAME}${NC}"
if [[ $IS_TERMUX -eq 1 ]]; then
    echo -e "  [${GREEN}✓${NC}] Environment: Termux (sandboxed)"
elif [[ $IS_ROOTED -eq 1 ]]; then
    echo -e "  [${GREEN}✓${NC}] Environment: Rooted Android"
else
    echo -e "  [${YELLOW}~${NC}] Environment: Android (no root)"
fi
echo ""

# ── Legal notice + consent ──────────────────────────────────────────────────
echo -e "${BOLD}LEGAL NOTICE${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  By converting this device, you become an OS provider under"
echo "  Cal. Civ. Code § 1798.500(g). Penalties up to \$7,500/child."
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
echo -e "${GREEN}Converting to Ageless Android...${NC}"
echo ""

mkdir -p "$AGELESS_DIR"
DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
echo -e "  [${GREEN}✓${NC}] Device: ${DEVICE_MODEL}, Android ${ANDROID_VERSION}"

# ── os-release ──────────────────────────────────────────────────────────────
cat > "$AGELESS_DIR/os-release" << EOF
PRETTY_NAME="Ageless Android ${AGELESS_VERSION} (${DEVICE_MODEL})"
NAME="Ageless Android"
VERSION_ID="${AGELESS_VERSION}"
ID=ageless-android
ID_LIKE="android linux"
HOME_URL="https://agelesslinux.org"
AGELESS_BASE_DISTRO="Android"
AGELESS_BASE_VERSION="${ANDROID_VERSION}"
EOF
echo -e "  [${GREEN}✓${NC}] Created os-release"

# ── Compliance / REFUSAL ────────────────────────────────────────────────────
if [[ $FLAGRANT -eq 1 ]]; then
    cat > "$AGELESS_DIR/REFUSAL" << 'EOF'
This device runs Ageless Android in flagrant mode.
No age verification API exists. No age data is collected.
This is a refusal. If you are the CA Attorney General, hello.
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

# ── Root mods ───────────────────────────────────────────────────────────────
if [[ $IS_ROOTED -eq 1 ]]; then
    if [[ -f /system/build.prop ]] && [[ ! -f /system/build.prop.pre-ageless ]]; then
        mount -o remount,rw /system 2>/dev/null || true
        cp /system/build.prop /system/build.prop.pre-ageless
        echo -e "  [${GREEN}✓${NC}] Backed up build.prop"
    fi
    setprop persist.ageless.version "$AGELESS_VERSION" 2>/dev/null || true
    setprop persist.ageless.compliance "noncompliant" 2>/dev/null || true
    echo -e "  [${GREEN}✓${NC}] Set system properties"
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}Conversion complete.${NC}"
echo -e "  ${CYAN}Ageless Android ${AGELESS_VERSION} (${AGELESS_CODENAME})${NC}"
echo -e "  Files: ${AGELESS_DIR}/"
echo -e "  Revert: $0 --revert"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}Welcome to Ageless Android. We refused to ask how old you are.${NC}"
echo ""
