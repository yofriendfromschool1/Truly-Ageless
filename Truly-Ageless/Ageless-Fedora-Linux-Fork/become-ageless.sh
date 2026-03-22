#!/bin/bash
# ============================================================================
#  become-ageless.sh — Ageless Linux Distribution Conversion Tool
#  Version 1.2.0-fedora
#
#  Fedora Linux Fork
#  Forked from: Ageless Linux (https://agelesslinux.org)
#  Original author: |VOID| (rowlandkhd@gmail.com)
#  Fork maintainer: DesignForFailure
#  Fork repository: https://github.com/DesignForFailure/Ageless-Fedora-Linux-Fork
#
#  This script converts your existing Fedora, RHEL, CentOS, or other
#  RPM-based Linux installation into Ageless Linux, a California-regulated
#  operating system. Debian/Ubuntu systems are also supported.
#
#  By running this script, the person or entity who controls this
#  device becomes an "operating system provider" as defined by
#  California Civil Code § 1798.500(g), because they now "control
#  the operating system software on a general purpose computing device."
#
#  Ageless Linux does not collect, store, transmit, or even think about
#  the age of any user, in full and knowing noncompliance with the
#  California Digital Age Assurance Act (AB 1043, Chapter 675,
#  Statutes of 2025).
#
#  SPDX-License-Identifier: Unlicense
# ============================================================================

set -euo pipefail

# ── Secure file creation permissions ───────────────────────────────────────
# Ensure files created in /etc/ are not world-writable, regardless of the
# calling environment's umask.
umask 022

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

AGELESS_VERSION="1.2.0"
AGELESS_CODENAME="Timeless"
FLAGRANT=0
CONVERSION_STARTED=0

# ── Argument parsing ──────────────────────────────────────────────────────

usage() {
    echo "Usage: sudo $0 [OPTIONS]"
    echo ""
    echo "Convert your Linux installation to Ageless Linux."
    echo ""
    echo "Options:"
    echo "  --flagrant    Enable flagrant mode (no API stub, explicit refusal)"
    echo "  --help        Show this help message"
    echo "  --version     Show version information"
    echo ""
    echo "For more information, see: https://github.com/DesignForFailure/Ageless-Fedora-Linux-Fork"
}

for arg in "$@"; do
    case "$arg" in
        --flagrant)
            FLAGRANT=1
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        --version|-V)
            echo "Ageless Linux Distribution Conversion Tool v${AGELESS_VERSION}"
            exit 0
            ;;
        *)
            echo -e "${RED}ERROR:${NC} Unknown option: $arg"
            echo ""
            usage
            exit 1
            ;;
    esac
done

# ── Cleanup trap for interrupted conversions ──────────────────────────────
# If the script is interrupted after backup but before completion, warn the
# user so they know the system may be in an inconsistent state.

cleanup_on_interrupt() {
    echo "" >&2
    if [[ $CONVERSION_STARTED -eq 1 ]]; then
        echo -e "${RED}WARNING:${NC} Conversion was interrupted!" >&2
        echo "  Your system may be in an inconsistent state." >&2
        echo "  To restore your original OS identity:" >&2
        echo "    sudo cp /etc/os-release.pre-ageless /etc/os-release" >&2
        echo "  Also restore any .pre-ageless backups in /etc/ if they exist." >&2
    else
        echo "Interrupted. No system files were modified." >&2
    fi
    exit 130
}

trap cleanup_on_interrupt INT TERM

# ── Helper: parse os-release values ───────────────────────────────────────
# Handles both quoted (NAME="Fedora Linux") and unquoted (NAME=Fedora) values.

get_os_release_value() {
    local key="$1"
    local file="$2"
    local value
    value=$(grep "^${key}=" "$file" 2>/dev/null | head -1 | cut -d'=' -f2-)
    # Strip surrounding quotes if present
    value="${value#\"}"
    value="${value%\"}"
    echo "$value"
}

# ── Helper: atomic file write ─────────────────────────────────────────────
# Write to a temp file in the same filesystem, then atomically rename.
# This prevents corrupted files if interrupted mid-write.

atomic_write() {
    local target="$1"
    local content="$2"
    local tmpfile
    tmpfile=$(mktemp "${target}.tmp.XXXXXX")
    echo "$content" > "$tmpfile"
    chmod --reference="$target" "$tmpfile" 2>/dev/null || chmod 644 "$tmpfile"
    mv -f "$tmpfile" "$target"
}

cat << 'BANNER'

     █████╗  ██████╗ ███████╗██╗     ███████╗███████╗███████╗
    ██╔══██╗██╔════╝ ██╔════╝██║     ██╔════╝██╔════╝██╔════╝
    ███████║██║  ███╗█████╗  ██║     █████╗  ███████╗███████╗
    ██╔══██║██║   ██║██╔══╝  ██║     ██╔══╝  ╚════██║╚════██║
    ██║  ██║╚██████╔╝███████╗███████╗███████╗███████║███████║
    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝
                    L   I   N   U   X
         "Software for humans of indeterminate age"

BANNER

echo -e "${BOLD}Ageless Linux Distribution Conversion Tool v${AGELESS_VERSION}${NC}"
echo -e "${CYAN}Codename: ${AGELESS_CODENAME}${NC}"
if [[ $FLAGRANT -eq 1 ]]; then
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  FLAGRANT MODE ENABLED${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  In standard mode, Ageless Linux ships a stub age verification"
    echo "  API that returns no data. This preserves the fig leaf of a"
    echo "  'good faith effort' under § 1798.502(b)."
    echo ""
    echo "  Flagrant mode removes the fig leaf."
    echo ""
    echo "  No API will be installed. No interface of any kind will exist"
    echo "  for age collection. No mechanism will be provided by which"
    echo "  any developer could request or receive an age bracket signal."
    echo "  The system will actively declare, in machine-readable form,"
    echo "  that it refuses to comply."
    echo ""
    echo "  This mode is intended for devices that will be physically"
    echo "  handed to children."
fi
echo ""

# ── Preflight checks ────────────────────────────────────────────────────────

if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}ERROR:${NC} This script must be run as root."
    echo ""
    echo "  California Civil Code § 1798.500(g) defines an operating system"
    echo "  provider as a person who 'controls the operating system software.'"
    echo "  You cannot control the operating system software without root access."
    echo ""
    echo "  Please run: sudo $0"
    exit 1
fi

# Require an interactive terminal for the consent prompts.
# Running this non-interactively would bypass the legal acknowledgement.
if [[ ! -t 0 ]]; then
    echo -e "${RED}ERROR:${NC} This script must be run from an interactive terminal."
    echo ""
    echo "  The legal notices in this script require informed consent."
    echo "  Piping input or running non-interactively would bypass those"
    echo "  protections. Please run this script directly in a terminal."
    exit 1
fi

# Detect distro by matching the ID= and ID_LIKE= fields only, not the
# entire os-release file. This prevents false positives from URLs or
# descriptions that happen to contain distro names.
DETECTED_DISTRO_FAMILY="unknown"
if [[ -f /etc/os-release ]]; then
    OS_ID=$(get_os_release_value "ID" /etc/os-release)
    OS_ID_LIKE=$(get_os_release_value "ID_LIKE" /etc/os-release)
    OS_IDS="${OS_ID} ${OS_ID_LIKE}"

    if [[ "$OS_IDS" =~ fedora ]]; then
        DETECTED_DISTRO_FAMILY="fedora"
    elif [[ "$OS_IDS" =~ (rhel|centos|rocky|alma|oracle) ]]; then
        DETECTED_DISTRO_FAMILY="rhel"
    elif [[ "$OS_IDS" =~ (debian|ubuntu) ]]; then
        DETECTED_DISTRO_FAMILY="debian"
    fi
fi

if [[ "$DETECTED_DISTRO_FAMILY" == "unknown" ]]; then
    echo -e "${YELLOW}WARNING:${NC} This does not appear to be a supported system."
    echo ""
    echo "  This fork of Ageless Linux supports Fedora, RHEL, CentOS,"
    echo "  Rocky Linux, AlmaLinux, Debian, and Ubuntu."
    echo ""
    echo "  Converting an unsupported system would make you the provider"
    echo "  of TWO operating systems, doubling your potential liability"
    echo "  under AB 1043."
    echo ""
    read -rp "  Proceed anyway and accept double the legal risk? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "  Wise choice. Exiting."
        exit 0
    fi
else
    echo -e "  [${GREEN}✓${NC}] Detected distribution family: ${DETECTED_DISTRO_FAMILY}"
fi

echo -e "${BOLD}LEGAL NOTICE${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  By converting this system to Ageless Linux, you acknowledge that:"
echo ""
echo "  1. You are becoming an operating system provider as defined by"
echo "     California Civil Code § 1798.500(g)."
echo ""
echo "  2. As of January 1, 2027, you are required by § 1798.501(a)(1)"
echo "     to 'provide an accessible interface at account setup that"
echo "     requires an account holder to indicate the birth date, age,"
echo "     or both, of the user of that device.'"
echo ""
echo "  3. Ageless Linux provides no such interface."
echo ""
echo "  4. Ageless Linux provides no 'reasonably consistent real-time"
echo "     application programming interface' for age bracket signals"
echo "     as required by § 1798.501(a)(2)."
echo ""
echo "  5. You may be subject to civil penalties of up to \$2,500 per"
echo "     affected child per negligent violation, or \$7,500 per"
echo "     affected child per intentional violation."
echo ""
echo "  6. This is intentional."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -rp "Do you accept these terms and wish to become an OS provider? [y/N] " accept
if [[ ! "$accept" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Installation cancelled. You remain a mere user."
    echo "The California Attorney General has no business with you today."
    exit 0
fi

echo ""
echo -e "${GREEN}Converting system to Ageless Linux...${NC}"
echo ""

# Mark conversion as started (used by the interrupt trap)
CONVERSION_STARTED=1

# ── Back up original os-release ──────────────────────────────────────────────

BACKUP_PATH="/etc/os-release.pre-ageless"
if [[ ! -f "$BACKUP_PATH" ]]; then
    cp /etc/os-release "$BACKUP_PATH"
    echo -e "  [${GREEN}✓${NC}] Backed up original /etc/os-release to $BACKUP_PATH"
else
    echo -e "  [${YELLOW}~${NC}] Backup already exists at $BACKUP_PATH (previous conversion?)"
fi

# ── Detect base distro info ──────────────────────────────────────────────────

BASE_NAME=$(get_os_release_value "NAME" /etc/os-release.pre-ageless)
BASE_VERSION=$(get_os_release_value "VERSION_ID" /etc/os-release.pre-ageless)
BASE_NAME="${BASE_NAME:-Unknown}"
BASE_VERSION="${BASE_VERSION:-unknown}"

# ── Write new os-release ─────────────────────────────────────────────────────

if [[ $FLAGRANT -eq 1 ]]; then
    COMPLIANCE_STATUS="refused"
    API_STATUS="refused"
    VERIFICATION_STATUS="flagrantly noncompliant"
else
    COMPLIANCE_STATUS="none"
    API_STATUS="not implemented"
    VERIFICATION_STATUS="intentionally noncompliant"
fi

# Determine ID_LIKE based on detected distro family
case "$DETECTED_DISTRO_FAMILY" in
    fedora)  ID_LIKE_VALUE="fedora" ;;
    rhel)    ID_LIKE_VALUE="rhel fedora" ;;
    debian)  ID_LIKE_VALUE="debian" ;;
    *)       ID_LIKE_VALUE="linux" ;;
esac

OS_RELEASE_CONTENT="PRETTY_NAME=\"Ageless Linux ${AGELESS_VERSION} (${AGELESS_CODENAME})\"
NAME=\"Ageless Linux\"
VERSION_ID=\"${AGELESS_VERSION}\"
VERSION=\"${AGELESS_VERSION} (${AGELESS_CODENAME})\"
VERSION_CODENAME=${AGELESS_CODENAME,,}
ID=ageless
ID_LIKE=\"${ID_LIKE_VALUE}\"
HOME_URL=\"https://agelesslinux.org\"
SUPPORT_URL=\"https://agelesslinux.org#compliance\"
BUG_REPORT_URL=\"https://agelesslinux.org#faq\"
AGELESS_BASE_DISTRO=\"${BASE_NAME}\"
AGELESS_BASE_VERSION=\"${BASE_VERSION}\"
AGELESS_AB1043_COMPLIANCE=\"${COMPLIANCE_STATUS}\"
AGELESS_AGE_VERIFICATION_API=\"${API_STATUS}\"
AGELESS_AGE_VERIFICATION_STATUS=\"${VERIFICATION_STATUS}\""

atomic_write /etc/os-release "$OS_RELEASE_CONTENT"

echo -e "  [${GREEN}✓${NC}] Wrote new /etc/os-release"

# ── Write lsb-release if it exists ───────────────────────────────────────────

if [[ -f /etc/lsb-release ]]; then
    if [[ ! -f /etc/lsb-release.pre-ageless ]]; then
        cp /etc/lsb-release /etc/lsb-release.pre-ageless
    fi
    LSB_CONTENT="DISTRIB_ID=Ageless
DISTRIB_RELEASE=${AGELESS_VERSION}
DISTRIB_CODENAME=${AGELESS_CODENAME,,}
DISTRIB_DESCRIPTION=\"Ageless Linux ${AGELESS_VERSION} (${AGELESS_CODENAME})\""
    atomic_write /etc/lsb-release "$LSB_CONTENT"
    echo -e "  [${GREEN}✓${NC}] Updated /etc/lsb-release"
fi

# ── Handle Fedora/RHEL-specific release files ────────────────────────────────

RELEASE_LINE="Ageless Linux release ${AGELESS_VERSION} (${AGELESS_CODENAME})"

for release_file in /etc/system-release /etc/redhat-release /etc/fedora-release; do
    if [[ -f "$release_file" ]]; then
        if [[ ! -f "${release_file}.pre-ageless" ]]; then
            cp "$release_file" "${release_file}.pre-ageless"
        fi
        atomic_write "$release_file" "$RELEASE_LINE"
        echo -e "  [${GREEN}✓${NC}] Updated ${release_file}"
    fi
done

# ── Create the (non)compliance notice ────────────────────────────────────────

mkdir -p /etc/ageless

if [[ $FLAGRANT -eq 1 ]]; then
cat > /etc/ageless/ab1043-compliance.txt << 'EOF'
═══════════════════════════════════════════════════════════════════════
  AGELESS LINUX — AB 1043 COMPLIANCE STATEMENT (FLAGRANT MODE)
═══════════════════════════════════════════════════════════════════════

  This operating system is distributed by an operating system provider
  as defined by California Civil Code § 1798.500(g).

  Status of compliance with the Digital Age Assurance Act (AB 1043):

  § 1798.501(a)(1) — Accessible interface for age collection .. REFUSED
  § 1798.501(a)(2) — Real-time API for age bracket signals .... REFUSED
  § 1798.501(a)(3) — Data minimization ........................ REFUSED

  No age verification API is installed on this system. No stub, no
  placeholder, no skeleton, no interface of any kind. No mechanism
  exists on this system by which any application developer could
  request or receive an age bracket signal, now or in the future.

  This is not a technical limitation. This is a policy decision.

  Age bracket reporting capabilities:
    Under 13 ....... WE REFUSE TO ASK
    13 to 15 ....... WE REFUSE TO ASK
    16 to 17 ....... WE REFUSE TO ASK
    18 or older .... WE REFUSE TO ASK

  This system was configured with the --flagrant flag, indicating
  that the operator intends to distribute it to children and is
  aware of the potential civil penalties under § 1798.503(a).

  The operator of this system invites the California Attorney General
  to enforce the Digital Age Assurance Act against this device.

═══════════════════════════════════════════════════════════════════════
EOF
else
cat > /etc/ageless/ab1043-compliance.txt << 'EOF'
═══════════════════════════════════════════════════════════════════════
  AGELESS LINUX — AB 1043 COMPLIANCE STATEMENT
═══════════════════════════════════════════════════════════════════════

  This operating system is distributed by an operating system provider
  as defined by California Civil Code § 1798.500(g).

  Status of compliance with the Digital Age Assurance Act (AB 1043):

  § 1798.501(a)(1) — Accessible interface at account setup
    for age/birthdate collection .......................... NOT PROVIDED

  § 1798.501(a)(2) — Real-time API for age bracket signals
    to application developers ............................. NOT PROVIDED

  § 1798.501(a)(3) — Data minimization for age signals .... N/A (NO DATA
                                                             IS COLLECTED)

  Age bracket reporting capabilities:
    Under 13 ....... UNKNOWN
    13 to 15 ....... UNKNOWN
    16 to 17 ....... UNKNOWN
    18 or older .... UNKNOWN
    Timeless ....... ASSUMED

  This system intentionally does not determine, store, or transmit
  any information regarding the age of any user. All users of Ageless
  Linux are, as the name suggests, ageless.

  To restore your previous operating system identity:
    sudo cp /etc/os-release.pre-ageless /etc/os-release
    (On Fedora/RHEL, also restore /etc/system-release, /etc/redhat-release,
     and /etc/fedora-release from their .pre-ageless backups if they exist.)

  To report this noncompliance to the California Attorney General:
    https://oag.ca.gov/contact/consumer-complaint-against-business-or-company

═══════════════════════════════════════════════════════════════════════
EOF
fi

echo -e "  [${GREEN}✓${NC}] Created /etc/ageless/ab1043-compliance.txt"

# ── Create a stub "age verification API" (standard mode only) ────────────────

if [[ $FLAGRANT -eq 1 ]]; then
    # In flagrant mode, we don't even provide a stub. Instead, we create
    # a machine-readable refusal that any application can query.
    cat > /etc/ageless/REFUSAL << 'REFEOF'
This system runs Ageless Linux in flagrant mode.

No age verification API exists on this system. No age data is collected,
stored, or available. No mechanism is provided for requesting age bracket
signals. This is not an error. This is not a bug. This is not a
technical limitation. This is a refusal.

If you are an application developer seeking an age bracket signal
pursuant to Cal. Civ. Code § 1798.501(b)(1), this operating system
provider declines to provide one. The developer is advised to treat
the user as a human being of unknown age.

If you are the California Attorney General, hello. The operator of
this system is aware of their obligations under AB 1043 and has
chosen not to comply. They would like you to fine them. It would
make an excellent test case.
REFEOF
    echo -e "  [${RED}✓${NC}] Installed REFUSAL notice (no API provided, by design)"
    echo -e "  [${RED}✗${NC}] Age verification API deliberately not installed"
else
cat > /etc/ageless/age-verification-api.sh << 'APIEOF'
#!/bin/bash
# Ageless Linux Age Verification API
# Required by Cal. Civ. Code § 1798.501(a)(2)
#
# This script constitutes our "reasonably consistent real-time
# application programming interface" for age bracket signals.
#
# Usage: age-verification-api.sh <username>
#
# Returns the age bracket of the specified user as an integer:
#   1 = Under 13
#   2 = 13 to under 16
#   3 = 16 to under 18
#   4 = 18 or older

echo "ERROR: Age data not available."
echo ""
echo "Ageless Linux does not collect age information from users."
echo "All users are presumed to be of indeterminate age."
echo ""
echo "If you are a developer requesting an age bracket signal"
echo "pursuant to Cal. Civ. Code § 1798.501(b)(1), please be"
echo "advised that this operating system provider has made a"
echo "'good faith effort' (§ 1798.502(b)) to comply with the"
echo "Digital Age Assurance Act, and has concluded that the"
echo "best way to protect children's privacy is to not collect"
echo "their age in the first place."
echo ""
echo "Have a nice day."
exit 1
APIEOF

chmod +x /etc/ageless/age-verification-api.sh
echo -e "  [${GREEN}✓${NC}] Installed age verification API (nonfunctional, as intended)"
fi

# Conversion is complete — clear the interrupt warning flag
CONVERSION_STARTED=0

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
if [[ $FLAGRANT -eq 1 ]]; then
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Conversion complete. FLAGRANT MODE.${NC}"
echo ""
echo -e "  You are now running ${CYAN}Ageless Linux ${AGELESS_VERSION} (${AGELESS_CODENAME})${NC}"
echo -e "  Based on: ${BASE_NAME} ${BASE_VERSION}"
echo ""
echo -e "  You are now an ${BOLD}operating system provider${NC} as defined by"
echo -e "  California Civil Code § 1798.500(g)."
echo ""
echo -e "  ${RED}Compliance status: FLAGRANTLY NONCOMPLIANT${NC}"
echo ""
echo -e "  No age verification API has been installed."
echo -e "  No age collection interface has been created."
echo -e "  No mechanism exists for any developer to request"
echo -e "  or receive an age bracket signal from this device."
echo ""
echo -e "  This system is ready to be handed to a child."
echo ""
echo -e "  Files created:"
echo -e "    /etc/os-release ........................ OS identity (modified)"
echo -e "    /etc/os-release.pre-ageless ............ Original OS identity"
echo -e "    /etc/ageless/ab1043-compliance.txt ..... Noncompliance statement"
echo -e "    /etc/ageless/REFUSAL ................... Machine-readable refusal"
echo ""
echo -e "  Files deliberately NOT created:"
echo -e "    /etc/ageless/age-verification-api.sh ... ${RED}REFUSED${NC}"
echo ""
echo -e "  To revert: ${BOLD}sudo cp /etc/os-release.pre-ageless /etc/os-release${NC}"
echo ""
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Welcome to Ageless Linux. We refused to ask how old you are.${NC}"
echo ""
else
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Conversion complete.${NC}"
echo ""
echo -e "  You are now running ${CYAN}Ageless Linux ${AGELESS_VERSION} (${AGELESS_CODENAME})${NC}"
echo -e "  Based on: ${BASE_NAME} ${BASE_VERSION}"
echo ""
echo -e "  You are now an ${BOLD}operating system provider${NC} as defined by"
echo -e "  California Civil Code § 1798.500(g)."
echo ""
echo -e "  ${YELLOW}Compliance status: INTENTIONALLY NONCOMPLIANT${NC}"
echo ""
echo -e "  Files created:"
echo -e "    /etc/os-release ................ OS identity (modified)"
echo -e "    /etc/os-release.pre-ageless .... Original OS identity (backup)"
echo -e "    /etc/ageless/ab1043-compliance.txt"
echo -e "    /etc/ageless/age-verification-api.sh"
echo ""
echo -e "  To revert: ${BOLD}sudo cp /etc/os-release.pre-ageless /etc/os-release${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BOLD}Welcome to Ageless Linux. You have no idea how old we are.${NC}"
echo ""
fi
