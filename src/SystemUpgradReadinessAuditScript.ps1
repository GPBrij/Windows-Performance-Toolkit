# ===========================================
# System Upgrade Readiness Audit Script
# Forgiving / Non-Terminating / Logged
# ===========================================

$ExceptionLog = "C:\Tools\SystemUpgradeAudit.exceptions.log"

function Log-Exception {
    param (
        [string]$Section,
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp | $Section | $Message" | Out-File -Append -FilePath $ExceptionLog
}

Write-Host "=== SYSTEM UPGRADE READINESS AUDIT ===`n"

# -----------------------------
# System Identity
# -----------------------------
Write-Host "SYSTEM INFORMATION"
try {
    $system = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
    $bios   = Get-CimInstance Win32_BIOS -ErrorAction Stop
    $board  = Get-CimInstance Win32_BaseBoard -ErrorAction Stop

    $system | Select Manufacturer, Model, SystemType
    $bios   | Select Manufacturer, SMBIOSBIOSVersion, ReleaseDate
    $board  | Select Manufacturer, Product
}
catch {
    Log-Exception "System Identity" $_.Exception.Message
    Write-Host "System identity information unavailable"
}
Write-Host ""

# -----------------------------
# CPU Information
# -----------------------------
Write-Host "CPU INFORMATION"
try {
    $cpu = Get-CimInstance Win32_Processor -ErrorAction Stop
    $cpu | Select Name, Architecture, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, VirtualizationFirmwareEnabled
}
catch {
    Log-Exception "CPU Information" $_.Exception.Message
    Write-Host "CPU information unavailable"
}
Write-Host ""

# -----------------------------
# RAM Information
# -----------------------------
Write-Host "MEMORY (RAM)"
try {
    $ram = Get-CimInstance Win32_PhysicalMemory -ErrorAction Stop

    $totalRamBytes = ($ram | Measure-Object -Property Capacity -Sum).Sum
    $totalRamGB = [math]::Round($totalRamBytes / 1GB, 2)

    $ramType = switch ($ram[0].SMBIOSMemoryType) {
        20 { "DDR" }
        21 { "DDR2" }
        24 { "DDR3" }
        26 { "DDR4" }
        34 { "DDR5" }
        Default { "Unknown" }
    }

    Write-Host "Installed RAM (GB): $totalRamGB"
    Write-Host "RAM Type: $ramType"
    $ram | Select BankLabel, Manufacturer, Speed
}
catch {
    Log-Exception "RAM Information" $_.Exception.Message
    Write-Host "RAM information unavailable"
}
Write-Host ""

# -----------------------------
# OS Information
# -----------------------------
Write-Host "OPERATING SYSTEM"
try {
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
    $os | Select Caption, Version, BuildNumber, OSArchitecture
}
catch {
    Log-Exception "OS Information" $_.Exception.Message
    Write-Host "OS information unavailable"
}
Write-Host ""

# -----------------------------
# Storage Information
# -----------------------------
Write-Host "STORAGE"
try {
    Get-PhysicalDisk -ErrorAction Stop | Select FriendlyName, MediaType, BusType, Size
    Get-Disk -ErrorAction Stop | Select Number, PartitionStyle
}
catch {
    Log-Exception "Storage Information" $_.Exception.Message
    Write-Host "Storage information unavailable"
}
Write-Host ""

# -----------------------------
# Firmware / Boot
# -----------------------------
Write-Host "FIRMWARE"
try {
    Confirm-SecureBootUEFI -ErrorAction Stop
}
catch {
    Log-Exception "Firmware / Secure Boot" $_.Exception.Message
    Write-Host "Secure Boot status unavailable"
}
Write-Host ""

# -----------------------------
# TPM
# -----------------------------
Write-Host "TPM STATUS"
try {
    Get-Tpm -ErrorAction Stop | Select TpmPresent, TpmReady, SpecVersion
}
catch {
    Log-Exception "TPM" $_.Exception.Message
    Write-Host "TPM not detected or not accessible"
}
Write-Host ""

# -----------------------------
# Driver Health
# -----------------------------
Write-Host "DRIVER STATUS (Problems Only)"
try {
    Get-PnpDevice -ErrorAction Stop |
        Where-Object Status -ne "OK" |
        Select Class, FriendlyName, Status
}
catch {
    Log-Exception "Driver Health" $_.Exception.Message
    Write-Host "Driver health information unavailable"
}
Write-Host ""

# -----------------------------
# Upgrade Guidance Summary
# -----------------------------
Write-Host "UPGRADE READINESS SUMMARY"
try {
    if ($cpu -and $cpu.Architecture -eq 9) {
        Write-Host "CPU: 64-bit (OK for modern OS)"
    }
    elseif ($cpu) {
        Write-Host "CPU: 32-bit (OS upgrade limited)"
    }

    if ($ramType -eq "DDR3") {
        Write-Host "RAM: Upgrade possible but ageing"
    }
    elseif ($ramType -in "DDR4","DDR5") {
        Write-Host "RAM: Modern & expandable"
    }

    $diskStyle = Get-Disk -ErrorAction Stop | Where-Object PartitionStyle -eq "GPT"
    if ($diskStyle) {
        Write-Host "Disk: GPT (UEFI compatible)"
    }
    else {
        Write-Host "Disk: MBR (limits Windows 11 upgrade)"
    }

    $tpm = Get-Tpm -ErrorAction SilentlyContinue
    if ($tpm -and $tpm.TpmPresent) {
        Write-Host "TPM: Present"
    }
    else {
        Write-Host "TPM: Missing (Windows 11 blocked)"
    }
}
catch {
    Log-Exception "Upgrade Summary" $_.Exception.Message
    Write-Host "Upgrade summary partially unavailable"
}

Write-Host "`n=== AUDIT COMPLETE (FORGIVING MODE) ==="
