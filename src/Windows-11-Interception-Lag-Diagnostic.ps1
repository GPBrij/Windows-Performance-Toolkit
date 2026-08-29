Write-Host "=== Windows 11 Interception & Lag Diagnostic ===`n" -ForegroundColor Cyan

# -----------------------------
# 1. Startup Interception
# -----------------------------
Write-Host "`n[1] Startup Items (Non-Microsoft)" -ForegroundColor Yellow

$startupPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($path in $startupPaths) {
    if (Test-Path $path) {
        Get-ItemProperty $path |
        Select-Object * |
        Get-Member -MemberType NoteProperty |
        Where-Object { $_.Name -notmatch "SecurityHealth|OneDrive|Windows" } |
        ForEach-Object {
            Write-Host " - $($_.Name)" -ForegroundColor Red
        }
    }
}

# -----------------------------
# 2. Scheduled Tasks at Logon
# -----------------------------
Write-Host "`n[2] Scheduled Tasks Triggered At Logon" -ForegroundColor Yellow

Get-ScheduledTask |
Where-Object { $_.Triggers.TriggerType -contains "Logon" -and $_.Principal.UserId -ne "SYSTEM" } |
Select TaskName, TaskPath |
Format-Table -AutoSize

# -----------------------------
# 3. Shell Extensions (Explorer Interception)
# -----------------------------
Write-Host "`n[3] Non-Microsoft Shell Extensions" -ForegroundColor Yellow

$ShellExtKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved"
if (Test-Path $ShellExtKey) {
    Get-ItemProperty $ShellExtKey |
    Select-Object * |
    Get-Member -MemberType NoteProperty |
    Where-Object { $_.Name -notmatch "Microsoft|Windows" } |
    ForEach-Object {
        Write-Host " - Shell Extension: $($_.Name)" -ForegroundColor Red
    }
}

# -----------------------------
# 4. Antivirus / Filter Drivers
# -----------------------------
Write-Host "`n[4] File System Filter Drivers (Performance Impact?)" -ForegroundColor Yellow
fltmc | Select-Object -Skip 4

# -----------------------------
# 5. Active Security Products
# -----------------------------
Write-Host "`n[5] Security Products" -ForegroundColor Yellow

Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct |
Select displayName, productState |
Format-Table -AutoSize

# -----------------------------
# 6. High CPU Services
# -----------------------------
Write-Host "`n[6] Top CPU Consuming Services" -ForegroundColor Yellow

Get-Process |
Sort-Object CPU -Descending |
Select-Object -First 8 Name, CPU, WorkingSet |
Format-Table -AutoSize

# -----------------------------
# 7. Memory Pressure
# -----------------------------
Write-Host "`n[7] Memory Status" -ForegroundColor Yellow

Get-CimInstance Win32_OperatingSystem |
Select-Object TotalVisibleMemorySize, FreePhysicalMemory |
Format-List

# -----------------------------
# 8. Disk Latency
# -----------------------------
Write-Host "`n[8] Disk Queue Depth (Lag Indicator)" -ForegroundColor Yellow

Get-Counter '\PhysicalDisk(_Total)\Avg. Disk Queue Length' |
Select-Object -ExpandProperty CounterSamples |
Select CookedValue | ForEach-Object {
    Write-Host "Avg Disk Queue Length: $_"
}

# -----------------------------
# 9. Explorer / DWM Instability
# -----------------------------
Write-Host "`n[9] Explorer & Desktop Window Manager Status" -ForegroundColor Yellow

Get-Process explorer, dwm -ErrorAction SilentlyContinue |
Select Name, CPU, WorkingSet |
Format-Table -AutoSize

Write-Host "`n=== Diagnostic Complete ===" -ForegroundColor Cyan
``
