# Builds the Flutter Windows release and compiles it into a single
# WorldClock-Setup-<version>.exe installer using Inno Setup.
#
# Usage (from anywhere):
#   powershell -ExecutionPolicy Bypass -File installer\build_installer.ps1
#
# Requirements:
#   - Flutter SDK on PATH (flutter --version must work)
#   - Inno Setup 6 or 7 installed (https://jrsoftware.org/isdl.php)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

Write-Host "==> Building Flutter Windows release..." -ForegroundColor Cyan
flutter build windows --release
if ($LASTEXITCODE -ne 0) {
    throw "flutter build windows --release failed."
}

$releaseDir = Join-Path $root "build\windows\x64\runner\Release"
if (-not (Test-Path (Join-Path $releaseDir "world_time.exe"))) {
    throw "Expected build output not found at $releaseDir\world_time.exe"
}

# Locate the Inno Setup compiler (ISCC.exe). Checks PATH first, then the
# default install locations for both Inno Setup 7 and 6 (32-bit and 64-bit
# Program Files), newest version first.
$iscc = Get-Command "iscc.exe" -ErrorAction SilentlyContinue
if ($iscc) {
    $isccPath = $iscc.Source
} else {
    $candidates = @(
        "${Env:ProgramFiles}\Inno Setup 7\ISCC.exe",
        "${Env:ProgramFiles(x86)}\Inno Setup 7\ISCC.exe",
        "${Env:ProgramFiles}\Inno Setup 6\ISCC.exe",
        "${Env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe"
    )
    $found = $candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
    if (-not $found) {
        throw "Could not find ISCC.exe. Install Inno Setup from https://jrsoftware.org/isdl.php and re-run this script."
    }
    $isccPath = $found
}

Write-Host "==> Compiling installer with Inno Setup..." -ForegroundColor Cyan
& $isccPath (Join-Path $root "installer\setup.iss")
if ($LASTEXITCODE -ne 0) {
    throw "ISCC.exe failed to compile the installer."
}

$outputDir = Join-Path $root "installer\Output"
Write-Host ""
Write-Host "==> Done. Installer created in: $outputDir" -ForegroundColor Green
Get-ChildItem $outputDir -Filter "*.exe" | ForEach-Object { Write-Host "    $($_.FullName)" }
