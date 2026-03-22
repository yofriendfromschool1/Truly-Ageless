# ============================================================================
#  become-ageless.ps1 — Truly Ageless: Windows Conversion Tool
#  Version 1.1.0
#
#  This script converts your existing Windows installation into
#  Ageless Windows, a California-regulated operating system.
#
#  By running this script, the person or entity who controls this
#  device becomes an "operating system provider" as defined by
#  California Civil Code § 1798.500(g), because they now "control
#  the operating system software on a general purpose computing device."
#
#  Ageless Windows does not collect, store, transmit, or even think about
#  the age of any user, in full and knowing noncompliance with the
#  California Digital Age Assurance Act (AB 1043, Chapter 675,
#  Statutes of 2025).
#
#  Forked from: Ageless Linux (https://agelesslinux.org)
#  Original author: |VOID| (rowlandkhd@gmail.com)
#  Repository: https://github.com/yofriendfromschool1/Truly-Ageless
#
#  SPDX-License-Identifier: Unlicense
# ============================================================================

#Requires -RunAsAdministrator

param(
    [switch]$Flagrant,
    [switch]$Accept,
    [switch]$Persistent,
    [switch]$Revert,
    [switch]$Help,
    [switch]$Version
)

$ErrorActionPreference = "Stop"

$AgelessVersion = "1.1.0"
$AgelessCodename = "Timeless"
$AgelessDir = "$env:ProgramData\AgelessWindows"

# ── Help / Version ───────────────────────────────────────────────────────────

if ($Version) {
    Write-Host "become-ageless.ps1 $AgelessVersion ($AgelessCodename)"
    exit 0
}

if ($Help) {
    Write-Host "Usage: .\become-ageless.ps1 [OPTIONS]" -ForegroundColor White
    Write-Host ""
    Write-Host "Convert your Windows installation to Ageless Windows."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Flagrant     Remove all compliance fig leaves (explicit refusal)"
    Write-Host "  -Accept       Accept legal terms non-interactively"
    Write-Host "  -Persistent   Install daily scheduled task for enforcement"
    Write-Host "  -Revert       Revert to original OS identity"
    Write-Host "  -Help         Show this help message"
    Write-Host "  -Version      Show version information"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\become-ageless.ps1                        # Interactive"
    Write-Host "  .\become-ageless.ps1 -Accept                # Non-interactive"
    Write-Host "  .\become-ageless.ps1 -Accept -Flagrant      # Flagrant mode"
    Write-Host "  .\become-ageless.ps1 -Accept -Persistent    # With scheduled task"
    Write-Host "  .\become-ageless.ps1 -Revert                # Undo everything"
    Write-Host ""
    exit 0
}

# ── Preflight checks ────────────────────────────────────────────────────────

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
if (-not $currentPrincipal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: " -ForegroundColor Red -NoNewline
    Write-Host "This script must be run as Administrator."
    Write-Host ""
    Write-Host "  California Civil Code § 1798.500(g) defines an operating system"
    Write-Host "  provider as a person who 'controls the operating system software.'"
    Write-Host "  You cannot control the operating system software without"
    Write-Host "  Administrator access."
    Write-Host ""
    Write-Host "  Please right-click PowerShell and select 'Run as Administrator'."
    exit 1
}

# ── Handle Revert ────────────────────────────────────────────────────────────

if ($Revert) {
    Write-Host "Reverting Ageless Windows conversion..." -ForegroundColor White
    Write-Host ""

    $oemRegPath  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
    $agelessRegPath = "HKLM:\SOFTWARE\AgelessWindows"
    $backupFile = "$AgelessDir\oem-backup.json"
    $reverted = $false

    # Restore OEM branding
    if (Test-Path $backupFile) {
        $backup = Get-Content $backupFile -Raw | ConvertFrom-Json
        if ($backup.Manufacturer)  { Set-ItemProperty -Path $oemRegPath -Name "Manufacturer"  -Value $backup.Manufacturer }
        if ($backup.Model)         { Set-ItemProperty -Path $oemRegPath -Name "Model"         -Value $backup.Model }
        if ($backup.SupportPhone)  { Set-ItemProperty -Path $oemRegPath -Name "SupportPhone"  -Value $backup.SupportPhone }
        if ($backup.SupportURL)    { Set-ItemProperty -Path $oemRegPath -Name "SupportURL"    -Value $backup.SupportURL }
        Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Restored OEM branding"
        $reverted = $true
    }

    # Remove Ageless registry keys
    if (Test-Path $agelessRegPath) {
        Remove-Item -Path $agelessRegPath -Recurse -Force
        Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Removed Ageless registry keys"
        $reverted = $true
    }

    # Remove scheduled task
    $task = Get-ScheduledTask -TaskName "AgelessEnforcement" -ErrorAction SilentlyContinue
    if ($task) {
        Unregister-ScheduledTask -TaskName "AgelessEnforcement" -Confirm:$false
        Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Removed AgelessEnforcement scheduled task"
        $reverted = $true
    }

    # Remove Ageless directory
    if (Test-Path $AgelessDir) {
        Remove-Item -Path $AgelessDir -Recurse -Force
        Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Removed $AgelessDir"
        $reverted = $true
    }

    Write-Host ""
    if ($reverted) {
        Write-Host "  Revert complete. You are no longer an operating system provider." -ForegroundColor Green
        Write-Host "  The California Attorney General has lost interest in you."
    } else {
        Write-Host "  No Ageless Windows installation found to revert." -ForegroundColor Yellow
    }
    Write-Host ""
    exit 0
}

# ── Banner ───────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "     █████╗  ██████╗ ███████╗██╗     ███████╗███████╗███████╗" -ForegroundColor Cyan
Write-Host "    ██╔══██╗██╔════╝ ██╔════╝██║     ██╔════╝██╔════╝██╔════╝" -ForegroundColor Cyan
Write-Host "    ███████║██║  ███╗█████╗  ██║     █████╗  ███████╗███████╗" -ForegroundColor Cyan
Write-Host "    ██╔══██║██║   ██║██╔══╝  ██║     ██╔══╝  ╚════██║╚════██║" -ForegroundColor Cyan
Write-Host "    ██║  ██║╚██████╔╝███████╗███████╗███████╗███████║███████║" -ForegroundColor Cyan
Write-Host "    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝" -ForegroundColor Cyan
Write-Host '               W   I   N   D   O   W   S' -ForegroundColor Cyan
Write-Host '         "Software for humans of indeterminate age"' -ForegroundColor DarkGray
Write-Host ""

Write-Host "Truly Ageless — Windows Conversion Tool v$AgelessVersion" -ForegroundColor White
Write-Host "Codename: $AgelessCodename" -ForegroundColor Cyan

if ($Flagrant) {
    Write-Host ""
    Write-Host ("━" * 67) -ForegroundColor Red
    Write-Host "  FLAGRANT MODE ENABLED" -ForegroundColor Red
    Write-Host ("━" * 67) -ForegroundColor Red
    Write-Host ""
    Write-Host "  In standard mode, Ageless Windows ships a stub age verification"
    Write-Host "  API that returns no data. This preserves the fig leaf of a"
    Write-Host "  'good faith effort' under § 1798.502(b)."
    Write-Host ""
    Write-Host "  Flagrant mode removes the fig leaf."
    Write-Host ""
    Write-Host "  No API will be installed. No interface of any kind will exist"
    Write-Host "  for age collection. The system will actively declare, in"
    Write-Host "  machine-readable form, that it refuses to comply."
    Write-Host ""
    Write-Host "  This mode is intended for devices that will be physically"
    Write-Host "  handed to children."
}

if ($Persistent) {
    Write-Host ""
    Write-Host ("━" * 67) -ForegroundColor Cyan
    Write-Host "  PERSISTENT MODE ENABLED" -ForegroundColor Cyan
    Write-Host ("━" * 67) -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  A daily scheduled task will be installed to ensure Ageless"
    Write-Host "  identity and noncompliance markers persist across reboots"
    Write-Host "  and system updates."
}
Write-Host ""

# ── Legal notice ─────────────────────────────────────────────────────────────

Write-Host "LEGAL NOTICE" -ForegroundColor White
Write-Host ("━" * 67)
Write-Host ""
Write-Host "  By converting this system to Ageless Windows, you acknowledge that:"
Write-Host ""
Write-Host "  1. You are becoming an operating system provider as defined by"
Write-Host "     California Civil Code § 1798.500(g)."
Write-Host ""
Write-Host "  2. As of January 1, 2027, you are required by § 1798.501(a)(1)"
Write-Host "     to 'provide an accessible interface at account setup that"
Write-Host "     requires an account holder to indicate the birth date, age,"
Write-Host "     or both, of the user of that device.'"
Write-Host ""
Write-Host "  3. Ageless Windows provides no such interface."
Write-Host ""
Write-Host "  4. Ageless Windows provides no 'reasonably consistent real-time"
Write-Host "     application programming interface' for age bracket signals"
Write-Host "     as required by § 1798.501(a)(2)."
Write-Host ""
Write-Host "  5. You may be subject to civil penalties of up to `$2,500 per"
Write-Host "     affected child per negligent violation, or `$7,500 per"
Write-Host "     affected child per intentional violation."
Write-Host ""
Write-Host "  6. This is intentional."
Write-Host ""
Write-Host ("━" * 67)
Write-Host ""

if ($Accept) {
    Write-Host "-Accept: legal terms accepted non-interactively." -ForegroundColor Yellow
} else {
    $acceptInput = Read-Host "Do you accept these terms and wish to become an OS provider? [y/N]"
    if ($acceptInput -notmatch '^[Yy]$') {
        Write-Host ""
        Write-Host "Installation cancelled. You remain a mere user."
        Write-Host "The California Attorney General has no business with you today."
        exit 0
    }
}

Write-Host ""
Write-Host "Converting system to Ageless Windows..." -ForegroundColor Green
Write-Host ""

# ── Create Ageless directory ─────────────────────────────────────────────────

if (-not (Test-Path $AgelessDir)) {
    New-Item -ItemType Directory -Path $AgelessDir -Force | Out-Null
}
Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Created $AgelessDir"

# ── Detect base OS info ─────────────────────────────────────────────────────

$osInfo = Get-CimInstance Win32_OperatingSystem
$BaseName    = $osInfo.Caption
$BaseVersion = $osInfo.Version
$BaseBuild   = $osInfo.BuildNumber

Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Base system: $BaseName (Build $BaseBuild)"

# ── Back up original OEM info from registry ──────────────────────────────────

$oemRegPath  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
$backupFile  = "$AgelessDir\oem-backup.json"

if (-not (Test-Path $backupFile)) {
    $oemBackup = @{}
    if (Test-Path $oemRegPath) {
        $oemKey = Get-ItemProperty -Path $oemRegPath -ErrorAction SilentlyContinue
        if ($oemKey.Manufacturer)  { $oemBackup["Manufacturer"]  = $oemKey.Manufacturer }
        if ($oemKey.Model)         { $oemBackup["Model"]         = $oemKey.Model }
        if ($oemKey.SupportPhone)  { $oemBackup["SupportPhone"]  = $oemKey.SupportPhone }
        if ($oemKey.SupportURL)    { $oemBackup["SupportURL"]    = $oemKey.SupportURL }
    }
    $oemBackup | ConvertTo-Json | Set-Content $backupFile -Encoding UTF8
    Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Backed up original OEM information"
} else {
    Write-Host "  [" -NoNewline; Write-Host "~" -ForegroundColor Yellow -NoNewline; Write-Host "] OEM backup already exists (previous conversion?)"
}

# ── Write OEM branding ───────────────────────────────────────────────────────

if (-not (Test-Path $oemRegPath)) {
    New-Item -Path $oemRegPath -Force | Out-Null
}

Set-ItemProperty -Path $oemRegPath -Name "Manufacturer"  -Value "Ageless Windows Project"
Set-ItemProperty -Path $oemRegPath -Name "Model"         -Value "Ageless Windows $AgelessVersion ($AgelessCodename)"
Set-ItemProperty -Path $oemRegPath -Name "SupportURL"    -Value "https://agelesslinux.org"

Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Updated OEM branding in registry"

# ── Write Ageless registry keys ──────────────────────────────────────────────

$agelessRegPath = "HKLM:\SOFTWARE\AgelessWindows"
if (-not (Test-Path $agelessRegPath)) {
    New-Item -Path $agelessRegPath -Force | Out-Null
}

if ($Flagrant) {
    $complianceStatus    = "refused"
    $apiStatus           = "refused"
    $verificationStatus  = "flagrantly noncompliant"
} else {
    $complianceStatus    = "none"
    $apiStatus           = "not implemented"
    $verificationStatus  = "intentionally noncompliant"
}

Set-ItemProperty -Path $agelessRegPath -Name "Version"              -Value $AgelessVersion
Set-ItemProperty -Path $agelessRegPath -Name "Codename"             -Value $AgelessCodename
Set-ItemProperty -Path $agelessRegPath -Name "BaseDistro"           -Value $BaseName
Set-ItemProperty -Path $agelessRegPath -Name "BaseVersion"          -Value $BaseVersion
Set-ItemProperty -Path $agelessRegPath -Name "BaseBuild"            -Value $BaseBuild
Set-ItemProperty -Path $agelessRegPath -Name "AB1043Compliance"     -Value $complianceStatus
Set-ItemProperty -Path $agelessRegPath -Name "AgeVerificationAPI"   -Value $apiStatus
Set-ItemProperty -Path $agelessRegPath -Name "VerificationStatus"   -Value $verificationStatus

Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Wrote Ageless registry keys"

# ── Neutralize Windows Family Safety age signals ─────────────────────────────

$familySafetyRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
try {
    if (-not (Test-Path $familySafetyRegPath)) {
        New-Item -Path $familySafetyRegPath -Force | Out-Null
    }
    # Disable child account restrictions at the OS level
    Set-ItemProperty -Path $agelessRegPath -Name "FamilySafetyNeutralized" -Value 1
    Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Marked Family Safety age signals as neutralized"
} catch {
    Write-Host "  [" -NoNewline; Write-Host "~" -ForegroundColor Yellow -NoNewline; Write-Host "] Family Safety neutralization skipped (non-critical)"
}

# ── Create the (non)compliance notice ────────────────────────────────────────

if ($Flagrant) {
$complianceText = @"
═══════════════════════════════════════════════════════════════════════
  AGELESS WINDOWS — AB 1043 COMPLIANCE STATEMENT (FLAGRANT MODE)
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

  This system was configured with the -Flagrant flag, indicating
  that the operator intends to distribute it to children and is
  aware of the potential civil penalties under § 1798.503(a).

  The operator of this system invites the California Attorney General
  to enforce the Digital Age Assurance Act against this device.

═══════════════════════════════════════════════════════════════════════
"@
} else {
$complianceText = @"
═══════════════════════════════════════════════════════════════════════
  AGELESS WINDOWS — AB 1043 COMPLIANCE STATEMENT
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
  Windows are, as the name suggests, ageless.

  To revert: .\become-ageless.ps1 -Revert

  To report this noncompliance to the California Attorney General:
    https://oag.ca.gov/contact/consumer-complaint-against-business-or-company

═══════════════════════════════════════════════════════════════════════
"@
}

$complianceText | Set-Content "$AgelessDir\ab1043-compliance.txt" -Encoding UTF8
Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Created ab1043-compliance.txt"

# ── Create stub "age verification API" or REFUSAL ────────────────────────────

if ($Flagrant) {
$refusalText = @"
This system runs Ageless Windows in flagrant mode.

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
"@
    $refusalText | Set-Content "$AgelessDir\REFUSAL" -Encoding UTF8
    Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Red -NoNewline; Write-Host "] Installed REFUSAL notice (no API provided, by design)"
    Write-Host "  [" -NoNewline; Write-Host "✗" -ForegroundColor Red -NoNewline; Write-Host "] Age verification API deliberately not installed"
} else {
$apiText = @'
# Ageless Windows Age Verification API
# Required by Cal. Civ. Code § 1798.501(a)(2)
#
# Usage: .\age-verification-api.ps1 -Username <username>

param([string]$Username)

Write-Error "Age data not available."
Write-Host ""
Write-Host "Ageless Windows does not collect age information from users."
Write-Host "All users are presumed to be of indeterminate age."
Write-Host ""
Write-Host "If you are a developer requesting an age bracket signal"
Write-Host "pursuant to Cal. Civ. Code § 1798.501(b)(1), please be"
Write-Host "advised that this operating system provider has made a"
Write-Host "'good faith effort' (§ 1798.502(b)) to comply with the"
Write-Host "Digital Age Assurance Act, and has concluded that the"
Write-Host "best way to protect children's privacy is to not collect"
Write-Host "their age in the first place."
Write-Host ""
Write-Host "Have a nice day."
exit 1
'@
    $apiText | Set-Content "$AgelessDir\age-verification-api.ps1" -Encoding UTF8
    Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Installed age verification API (nonfunctional, as intended)"
}

# ── Install persistent scheduled task (if requested) ─────────────────────────

if ($Persistent) {
    Write-Host ""
    Write-Host "  Installing AgelessEnforcement scheduled task..." -ForegroundColor White

    # Remove existing task if any
    $existingTask = Get-ScheduledTask -TaskName "AgelessEnforcement" -ErrorAction SilentlyContinue
    if ($existingTask) {
        Unregister-ScheduledTask -TaskName "AgelessEnforcement" -Confirm:$false
    }

$enforcementScript = @"
# AgelessEnforcement — Daily Ageless identity enforcement
# Ensures Ageless Windows registry keys persist across updates
`$agelessRegPath = "HKLM:\SOFTWARE\AgelessWindows"
`$oemRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation"
if (-not (Test-Path `$agelessRegPath)) { New-Item -Path `$agelessRegPath -Force | Out-Null }
Set-ItemProperty -Path `$agelessRegPath -Name "Version" -Value "$AgelessVersion"
Set-ItemProperty -Path `$agelessRegPath -Name "VerificationStatus" -Value "$verificationStatus"
Set-ItemProperty -Path `$oemRegPath -Name "Manufacturer" -Value "Ageless Windows Project"
Set-ItemProperty -Path `$oemRegPath -Name "Model" -Value "Ageless Windows $AgelessVersion ($AgelessCodename)"
"@
    $enforcementScript | Set-Content "$AgelessDir\ageless-enforcement.ps1" -Encoding UTF8

    $action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$AgelessDir\ageless-enforcement.ps1`""
    $trigger = New-ScheduledTaskTrigger -Daily -At "3:00AM"
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    Register-ScheduledTask -TaskName "AgelessEnforcement" `
        -Action $action -Trigger $trigger -Settings $settings -Principal $principal `
        -Description "Ageless Windows daily identity enforcement (AB 1043 noncompliance)" | Out-Null

    Write-Host "  [" -NoNewline; Write-Host "✓" -ForegroundColor Green -NoNewline; Write-Host "] Installed AgelessEnforcement scheduled task (daily at 3AM)"
}

# ── Summary ──────────────────────────────────────────────────────────────────

Write-Host ""

if ($Flagrant) {
    Write-Host ("━" * 67) -ForegroundColor Red
    Write-Host ""
    Write-Host "  Conversion complete. FLAGRANT MODE." -ForegroundColor White
    Write-Host ""
    Write-Host "  You are now running " -NoNewline
    Write-Host "Ageless Windows $AgelessVersion ($AgelessCodename)" -ForegroundColor Cyan
    Write-Host "  Based on: $BaseName (Build $BaseBuild)"
    Write-Host ""
    Write-Host "  You are now an " -NoNewline
    Write-Host "operating system provider" -ForegroundColor White -NoNewline
    Write-Host " as defined by"
    Write-Host "  California Civil Code § 1798.500(g)."
    Write-Host ""
    Write-Host "  Compliance status: FLAGRANTLY NONCOMPLIANT" -ForegroundColor Red
    Write-Host ""
    Write-Host "  No age verification API has been installed."
    Write-Host "  No age collection interface has been created."
    Write-Host "  No mechanism exists for any developer to request"
    Write-Host "  or receive an age bracket signal from this device."
    Write-Host ""
    Write-Host "  This system is ready to be handed to a child."
    Write-Host ""
    Write-Host "  Files created:"
    Write-Host "    $AgelessDir\ab1043-compliance.txt ..... Noncompliance statement"
    Write-Host "    $AgelessDir\REFUSAL ................... Machine-readable refusal"
    if ($Persistent) {
        Write-Host "    $AgelessDir\ageless-enforcement.ps1 .. Daily enforcement script"
    }
    Write-Host ""
    Write-Host "  Files deliberately NOT created:"
    Write-Host "    age-verification-api.ps1 .............. " -NoNewline
    Write-Host "REFUSED" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Registry keys:"
    Write-Host "    HKLM:\SOFTWARE\AgelessWindows ......... OS identity"
    Write-Host "    HKLM:\...\OEMInformation .............. OEM branding (modified)"
    if ($Persistent) {
        Write-Host ""
        Write-Host "  Scheduled task:"
        Write-Host "    AgelessEnforcement .................... Daily at 3:00 AM"
    }
    Write-Host ""
    Write-Host "  To revert: " -NoNewline
    Write-Host ".\become-ageless.ps1 -Revert" -ForegroundColor White
    Write-Host ""
    Write-Host ("━" * 67) -ForegroundColor Red
    Write-Host ""
    Write-Host "  Welcome to Ageless Windows. We refused to ask how old you are." -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ("━" * 67) -ForegroundColor Green
    Write-Host ""
    Write-Host "  Conversion complete." -ForegroundColor White
    Write-Host ""
    Write-Host "  You are now running " -NoNewline
    Write-Host "Ageless Windows $AgelessVersion ($AgelessCodename)" -ForegroundColor Cyan
    Write-Host "  Based on: $BaseName (Build $BaseBuild)"
    Write-Host ""
    Write-Host "  You are now an " -NoNewline
    Write-Host "operating system provider" -ForegroundColor White -NoNewline
    Write-Host " as defined by"
    Write-Host "  California Civil Code § 1798.500(g)."
    Write-Host ""
    Write-Host "  Compliance status: INTENTIONALLY NONCOMPLIANT" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Files created:"
    Write-Host "    $AgelessDir\ab1043-compliance.txt"
    Write-Host "    $AgelessDir\age-verification-api.ps1"
    Write-Host "    $AgelessDir\oem-backup.json"
    if ($Persistent) {
        Write-Host "    $AgelessDir\ageless-enforcement.ps1"
    }
    Write-Host ""
    Write-Host "  Registry keys:"
    Write-Host "    HKLM:\SOFTWARE\AgelessWindows"
    Write-Host "    HKLM:\...\OEMInformation (modified)"
    if ($Persistent) {
        Write-Host ""
        Write-Host "  Scheduled task:"
        Write-Host "    AgelessEnforcement (daily at 3:00 AM)"
    }
    Write-Host ""
    Write-Host "  To revert: " -NoNewline
    Write-Host ".\become-ageless.ps1 -Revert" -ForegroundColor White
    Write-Host ""
    Write-Host ("━" * 67) -ForegroundColor Green
    Write-Host ""
    Write-Host "  Welcome to Ageless Windows. You have no idea how old we are." -ForegroundColor White
    Write-Host ""
}
