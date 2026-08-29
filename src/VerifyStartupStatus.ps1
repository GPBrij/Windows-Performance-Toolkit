Write-Host "`n=== STARTUP VERIFICATION REPORT ===`n" -ForegroundColor Cyan

$appPatterns = "Teams|ms-teams|Copilot|Edge|Chrome|Firefox"

# Registry
Write-Host "1. Checking Startup Registry..." -ForegroundColor Yellow

$startupRegPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($path in $startupRegPaths) {
    Write-Host "`nRegistry Path: $path" -ForegroundColor Gray
    if (Test-Path $path) {
        $props = Get-ItemProperty $path -ErrorAction SilentlyContinue
        if ($props) {
            $matches =
                $props.PSObject.Properties |
                Where-Object { $_.Name -match $appPatterns }

            if ($matches) {
                $matches | ForEach-Object {
                    Write-Host "⚠️ ENABLED: $($_.Name)" -ForegroundColor Red
                }
            } else {
                Write-Host "✅ No matching startup entries found" -ForegroundColor Green
            }
        } else {
            Write-Host "✅ No matching startup entries found" -ForegroundColor Green
        }
    }
}

# Startup folders
Write-Host "`n2. Checking Startup Folder..." -ForegroundColor Yellow

$startupFolders = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "$env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\Startup"
)

foreach ($folder in $startupFolders) {
    Write-Host "`nFolder: $folder" -ForegroundColor Gray
    if (Test-Path $folder) {
        $items = Get-ChildItem $folder | Where-Object { $_.Name -match $appPatterns }
        if ($items) {
            $items | ForEach-Object {
                Write-Host "⚠️ ENABLED: $($_.Name)" -ForegroundColor Red
            }
        } else {
            Write-Host "✅ No startup shortcuts found" -ForegroundColor Green
        }
    }
}

# Scheduled tasks
Write-Host "`n3. Checking Scheduled Tasks..." -ForegroundColor Yellow

$tasks = Get-ScheduledTask | Where-Object { $_.TaskName -match $appPatterns }

if ($tasks) {
    foreach ($task in $tasks) {
        if ($task.State -ne "Disabled") {
            Write-Host "⚠️ ENABLED TASK: $($task.TaskName)" -ForegroundColor Red
        } else {
            Write-Host "✅ Disabled task: $($task.TaskName)" -ForegroundColor Green
        }
    }
} else {
    Write-Host "✅ No matching scheduled tasks found" -ForegroundColor Green
}

Write-Host "`n=== VERIFICATION COMPLETE ===`n" -ForegroundColor Cyan
