# BHAI Safety App - Automated APK Builder Script
# This script downloads Flutter, sets up paths, and compiles the APK automatically.

$ErrorActionPreference = "Stop"

# Define local workspace paths
$Workspace = Get-Location
$FlutterTempDir = Join-Path $Workspace "temp_flutter_sdk"
$FlutterZip = Join-Path $Workspace "flutter_sdk.zip"
$FlutterExe = Join-Path $FlutterTempDir "flutter\bin\flutter.bat"
$ApkSource = Join-Path $Workspace "bhai_app\build\app\outputs\flutter-apk\app-release.apk"
$ApkDestination = Join-Path $Workspace "bhai_app.apk"

# 1. Download Flutter SDK if not already present
if (-not (Test-Path $FlutterTempDir)) {
    Write-Host "====== [1/4] Downloading Flutter Stable SDK (~1GB)... ======" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $FlutterTempDir | Out-Null
    
    # URL for stable Windows release
    $FlutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.22.2-stable.zip"
    
    # Use BITS Transfer for fast background downloading with progress bar
    Start-BitsTransfer -Source $FlutterUrl -Destination $FlutterZip
    
    Write-Host "Extracting Flutter SDK zip archive..." -ForegroundColor Cyan
    Expand-Archive -Path $FlutterZip -DestinationPath $FlutterTempDir -Force
    Remove-Item -Path $FlutterZip -Force
} else {
    Write-Host "====== Flutter SDK already downloaded locally. ======" -ForegroundColor Green
}

# 2. Configure environment PATH temporarily for this process
$env:PATH = "$(Join-Path $FlutterTempDir 'flutter\bin');$env:PATH"
$env:ANDROID_HOME = "C:\Users\mahav\AppData\Local\Android\Sdk"
$env:JAVA_HOME = "D:\Software\jdk17"

Write-Host "====== [2/4] Verifying Flutter Environment... ======" -ForegroundColor Cyan
& $FlutterExe doctor

# Pipes 'y' to accept all prompts in PowerShell
"y","y","y","y","y","y","y","y" | & $FlutterExe doctor --android-licenses

# 4. Build Android Release APK
Write-Host "====== [4/4] Compiling Release APK... ======" -ForegroundColor Cyan
Set-Location -Path (Join-Path $Workspace "bhai_app")
& $FlutterExe pub get
& $FlutterExe build apk --release

# 5. Move output APK to root directory for easy download
if (Test-Path $ApkSource) {
    Copy-Item -Path $ApkSource -Destination $ApkDestination -Force
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "SUCCESS! Your release APK is compiled and ready for testing." -ForegroundColor Green
    Write-Host "Location: $ApkDestination" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
} else {
    Write-Error "Build succeeded, but compiled APK could not be found at target destination."
}

Set-Location -Path $Workspace
