# LocoGames — APK Build Script
# Usage: .\build_apk.ps1 [-FlutterPath <path>] [-Mode <debug|release|all>] [-Flavor <locogames|locodrinks|locobundle|all>]
#
# Examples:
#   .\build_apk.ps1                                          # Debug all flavors
#   .\build_apk.ps1 -FlutterPath "C:\flutter" -Mode all       # Debug + Release all flavors
#   .\build_apk.ps1 -Flavor locodrinks -Mode debug            # Debug LocoDrinks only
#   .\build_apk.ps1 -Mode release -Flavor locobundle          # Release LocoBundle only

param(
    [string]$FlutterPath = "",
    [ValidateSet("debug", "release", "all")]
    [string]$Mode = "debug",
    [ValidateSet("locogames", "locodrinks", "locobundle", "all")]
    [string]$Flavor = "all"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $ScriptDir) {
    $ScriptDir = Get-Location
}

Set-Location $ScriptDir

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Find-Flutter {
    if ($FlutterPath -and (Test-Path "$FlutterPath\bin\flutter.bat")) {
        return "$FlutterPath\bin\flutter.bat"
    }
    $whichFlutter = (Get-Command flutter -ErrorAction SilentlyContinue)
    if ($whichFlutter) {
        return "flutter"
    }
    $commonPaths = @(
        "C:\flutter\bin\flutter.bat",
        "C:\src\flutter\bin\flutter.bat",
        "$env:USERPROFILE\flutter\bin\flutter.bat",
        "$env:USERPROFILE\flutter_sdk\flutter\bin\flutter.bat",
        "C:\Users\pm-dev\flutter_sdk\flutter\bin\flutter.bat"
    )
    foreach ($p in $commonPaths) {
        if (Test-Path $p) {
            return $p
        }
    }
    Write-Host "ERROR: Flutter SDK not found." -ForegroundColor Red
    Write-Host "Install Flutter or use -FlutterPath to specify the Flutter SDK directory." -ForegroundColor Yellow
    Write-Host "Common install paths checked:" -ForegroundColor Yellow
    foreach ($p in $commonPaths) {
        Write-Host "  $p" -ForegroundColor DarkGray
    }
    exit 1
}

function Invoke-Build {
    param(
        [string]$FlutterCmd,
        [string]$TargetPlatform,
        [string]$BuildMode,
        [string]$FlavorName,
        [string]$EntryPoint,
        [string]$OutputName
    )

    Write-Host "Building: $OutputName ($BuildMode / $FlavorName)" -ForegroundColor White
    Write-Host "  Entry: $EntryPoint" -ForegroundColor DarkGray

    $args = @(
        "build", "apk",
        "--$BuildMode",
        "--flavor", $FlavorName,
        "--target", "lib/$EntryPoint",
        "--target-platform", $TargetPlatform
    )

    if ($BuildMode -eq "release" -and -not (Test-Path "android/key.properties")) {
        $args += "--no-tree-shake-icons"
        Write-Host "  NOTE: No key.properties found — APK will be unsigned." -ForegroundColor Yellow
        Write-Host "  For signed release builds, create android/key.properties with:" -ForegroundColor Yellow
        Write-Host "    storeFile=<path-to-keystore>" -ForegroundColor DarkGray
        Write-Host "    storePassword=<password>" -ForegroundColor DarkGray
        Write-Host "    keyAlias=<alias>" -ForegroundColor DarkGray
        Write-Host "    keyPassword=<password>" -ForegroundColor DarkGray
    }

    $proc = Start-Process -FilePath $FlutterCmd -ArgumentList $args -NoNewWindow -Wait -PassThru

    if ($proc.ExitCode -ne 0) {
        Write-Host "  FAILED with exit code $($proc.ExitCode)" -ForegroundColor Red
        return $false
    }

    $apkPattern = "build\app\outputs\flutter-apk\app-$FlavorName-$BuildMode*.apk"
    $builtApk = Get-ChildItem -Path $apkPattern | Sort-Object LastWriteTime -Descending | Select-Object -First 1

    if ($builtApk) {
        $outDir = "build\output"
        if (-not (Test-Path $outDir)) {
            New-Item -ItemType Directory -Path $outDir -Force | Out-Null
        }
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $destName = "${OutputName}_${BuildMode}_${timestamp}.apk"
        Copy-Item -Path $builtApk.FullName -Destination "$outDir\$destName" -Force
        $sizeMB = [math]::Round($builtApk.Length / 1MB, 1)
        Write-Host "  OK  $destName ($sizeMB MB)" -ForegroundColor Green
        return $true
    }

    Write-Host "  APK not found in output directory" -ForegroundColor Red
    return $false
}

$FlutterCmd = Find-Flutter
Write-Host "Flutter: $FlutterCmd" -ForegroundColor DarkGray
Write-Host "Mode: $Mode | Flavor: $Flavor" -ForegroundColor DarkGray

$flavors = @()
if ($Flavor -eq "all") {
    $flavors = @("locogames", "locodrinks", "locobundle")
} else {
    $flavors = @($Flavor)
}

$buildModes = @()
if ($Mode -eq "all") {
    $buildModes = @("debug", "release")
} else {
    $buildModes = @($Mode)
}

$entryPoints = @{
    "locogames"  = "main_locogames.dart"
    "locodrinks" = "main_locodrinks.dart"
    "locobundle" = "main_locobundle.dart"
}

$successCount = 0
$failCount = 0

foreach ($bm in $buildModes) {
    $targetPlatform = if ($bm -eq "debug") { "android-arm,android-arm64,android-x64" } else { "android-arm,android-arm64" }

    foreach ($flv in $flavors) {
        Write-Header "$bm / $flv"
        $entryPoint = $entryPoints[$flv]
        $outputName = "locogames_$flv"

        $result = Invoke-Build `
            -FlutterCmd $FlutterCmd `
            -TargetPlatform $targetPlatform `
            -BuildMode $bm `
            -FlavorName $flv `
            -EntryPoint $entryPoint `
            -OutputName $outputName

        if ($result) { $successCount++ } else { $failCount++ }
    }
}

Write-Header "BUILD COMPLETE"
Write-Host "Successful: $successCount" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "Failed: $failCount" -ForegroundColor Red
}

$outDir = "build\output"
if (Test-Path $outDir) {
    Write-Host ""
    Write-Host "APKs available in: $(Resolve-Path $outDir)" -ForegroundColor Cyan
    Get-ChildItem $outDir | ForEach-Object {
        $sizeMB = [math]::Round($_.Length / 1MB, 1)
        Write-Host "  $($_.Name) ($sizeMB MB)" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  Emulator / Testing Quick Reference" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Install on emulator:" -ForegroundColor White
Write-Host "    flutter emulators --launch <emulator_id>" -ForegroundColor DarkGray
Write-Host "    adb install build/output/locogames_locodrinks_debug_*.apk" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Install on device (debug):" -ForegroundColor White
Write-Host "    adb -d install build/output/locogames_locodrinks_debug_*.apk" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Build single flavor for quick testing:" -ForegroundColor White
Write-Host "    flutter build apk --debug --flavor locodrinks --target lib/main_locodrinks.dart" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Run directly on connected device:" -ForegroundColor White
Write-Host "    flutter run --flavor locodrinks --target lib/main_locodrinks.dart" -ForegroundColor DarkGray
Write-Host ""
