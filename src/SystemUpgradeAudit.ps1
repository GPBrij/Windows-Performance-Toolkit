# ===========================================
# System Upgrade Readiness Audit Script
# ===========================================
# Read-only | Safe | Admin recommended
# ===========================================

Write-Host "=== SYSTEM UPGRADE READINESS AUDIT ===`n"

# -----------------------------
# System Identity
# -----------------------------
$system = Get-CimInstance Win32_ComputerSystem
$bios   = Get-CimInstance Win32_BIOS
$board  = Get-CimInstance Win32_BaseBoard

Write-Host "SYSTEM INFORMATION"
$system | Select Manufacturer, Model, SystemType
$bios   | Select Manufacturer, SMBIOSBIOSVersion, ReleaseDate
$board  | Select Manufacturer, Product
Write-Host ""

# -----------------------------
# CPU Information
# -----------------------------
$cpu = Get-CimInstance Win32_Processor

Write-Host "CPU INFORMATION"
$cpu | Select Name, Architecture, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, VirtualizationFirmwareEnabled
Write-Host ""

# -----------------------------
# RAM Information (FIXED)
# -----------------------------
$ram = Get-CimInstance Win32_PhysicalMemory

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

Write-Host "MEMORY (RAM)"
Write-Host "Installed RAM (GB): $totalRamGB"
Write-Host "RAM Type: $ramType"
$ram | Select BankLabel, Manufacturer, Speed
Write-Host ""
# -----------------------------
# OS Information
# -----------------------------
$os = Get-CimInstance Win32_OperatingSystem

Write-Host "OPERATING SYSTEM"
$os | Select Caption, Version, BuildNumber, OSArchitecture
Write-Host ""

# -----------------------------
# Storage Information
# -----------------------------
Write-Host "STORAGE"
Get-PhysicalDisk | Select FriendlyName, MediaType, BusType, Size
Get-Disk | Select Number, PartitionStyle
Write-Host ""

# -----------------------------
# Firmware / Boot
# -----------------------------
Write-Host "FIRMWARE"
Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
Write-Host ""

# -----------------------------
# TPM
# -----------------------------
Write-Host "TPM STATUS"
Try {
    Get-Tpm | Select TpmPresent, TpmReady, SpecVersion
} Catch {
    Write-Host "TPM not detected"
}
Write-Host ""

# -----------------------------
# Driver Health
# -----------------------------
Write-Host "DRIVER STATUS (Problems Only)"
Get-PnpDevice | Where-Object Status -ne "OK" |
Select Class, FriendlyName, Status
Write-Host ""

# -----------------------------
# Upgrade Guidance Summary
# -----------------------------
Write-Host "UPGRADE READINESS SUMMARY"

if ($cpu.Architecture -eq 9) {
    Write-Host "CPU: 64-bit (OK for modern OS)"
} else {
    Write-Host "CPU: 32-bit (OS upgrade limited)"
}

if ($ramType -eq "DDR3") {
    Write-Host "RAM: Upgrade possible but ageing"
}
elseif ($ramType -in "DDR4","DDR5") {
    Write-Host "RAM: Modern & expandable"
}

if ((Get-Disk | Where PartitionStyle -eq "GPT")) {
    Write-Host "Disk: GPT (UEFI compatible)"
} else {
    Write-Host "Disk: MBR (limits Windows 11 upgrade)"
}

if ((Get-Tpm).TpmPresent -eq $true) {
    Write-Host "TPM: Present"
} else {
    Write-Host "TPM: Missing (Windows 11 blocked)"
}

Write-Host "`n=== AUDIT COMPLETE ==="
