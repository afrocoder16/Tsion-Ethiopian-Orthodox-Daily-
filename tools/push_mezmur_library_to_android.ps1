$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$librarySource = Join-Path $repoRoot 'assets\mezmuer\library'
$adbPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
$applicationId = 'com.example.tsion_orthodox_daily_app'
$deviceRoot = "/sdcard/Android/data/$applicationId/files/mezmuer"

if (-not (Test-Path -LiteralPath $librarySource)) {
  throw "Library source not found: $librarySource"
}

if (-not (Test-Path -LiteralPath $adbPath)) {
  throw "adb.exe not found at $adbPath"
}

$deviceLines = & $adbPath devices | Select-String 'device$'
if (-not $deviceLines) {
  throw 'No Android device or emulator is connected.'
}

Write-Host "Preparing device folder $deviceRoot ..."
& $adbPath shell "mkdir -p $deviceRoot"

Write-Host 'Removing previously synced mezmur library from the device ...'
& $adbPath shell "rm -rf $deviceRoot/library"

Write-Host 'Pushing cleaned mezmur library to the connected device ...'
& $adbPath push $librarySource $deviceRoot

Write-Host 'Done.'
Write-Host "The library is now under $deviceRoot/library"
