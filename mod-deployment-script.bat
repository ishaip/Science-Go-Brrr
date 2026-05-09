@echo off
setlocal enabledelayedexpansion

REM Deployment script for Every Research Costs One mod
REM Reads name/version from info.json & changelog.txt, packages, and deploys to Factorio mods folder.

REM Read version from changelog.txt (first occurrence only)
set version=
for /f "tokens=2" %%a in ('findstr /r "^Version:" changelog.txt 2^>nul') do (
    if "!version!"=="" set version=%%a
)

if "!version!"=="" (
    echo Error: Could not find version in changelog.txt
    echo Expected format: "Version: x.x.x"
    pause
    exit /b 1
)

REM Read mod name from info.json
set modname=
for /f "tokens=2 delims=:," %%a in ('findstr /r "\"name\":" info.json 2^>nul') do (
    set modname=%%a
    set modname=!modname:"=!
    set modname=!modname: =!
)

if "!modname!"=="" (
    echo Error: Could not find mod name in info.json
    pause
    exit /b 1
)

echo Found mod name: !modname!
echo Found version: !version!

set foldername=!modname!_!version!
set zipname=!foldername!.zip
set target=%appdata%\Factorio\mods

REM Remove existing folder and zip if they exist
if exist "!foldername!" rmdir /s /q "!foldername!"
if exist "!zipname!" del /f /q "!zipname!"

echo Creating mod folder: !foldername!

mkdir "!foldername!"

REM Copy mod files (skip repo/dev files)
echo Copying files to mod folder...
for /f "delims=" %%i in ('dir /b /a-d') do (
    if /I not "%%i"==".gitignore" (
    if /I not "%%i"==".gitattributes" (
    if /I not "%%i"==".releaserc" (
    if /I not "%%i"=="mod-deployment-script.bat" (
        copy "%%i" "!foldername!\" >nul
    ))))
)

REM Copy directories needed by the mod (locale), skip repo/dev directories
for /f "delims=" %%i in ('dir /b /ad') do (
    if /I not "%%i"==".git" (
    if /I not "%%i"==".github" (
    if /I not "%%i"==".vscode" (
    if /I not "%%i"==".assets" (
    if /I not "%%i"==".scripts" (
    if /I not "%%i"=="!foldername!" (
        xcopy "%%i" "!foldername!\%%i\" /e /i /q >nul
    ))))))
)

echo Creating zip archive: !zipname!

REM Create zip with forward slashes using .NET (compatible with Factorio mod portal)
powershell -Command ^
  "Add-Type -AssemblyName System.IO.Compression.FileSystem; " ^
  "$folder = '!foldername!'; " ^
  "$zipPath = (Join-Path $PWD '!zipname!'); " ^
  "if (Test-Path $zipPath) { Remove-Item $zipPath }; " ^
  "$zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create'); " ^
  "Get-ChildItem $folder -Recurse -File | ForEach-Object { " ^
  "  $entry = $_.FullName.Substring((Resolve-Path $PWD).Path.Length + 1).Replace('\', '/'); " ^
  "  [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $entry) | Out-Null " ^
  "}; " ^
  "$zip.Dispose(); " ^
  "Write-Host 'Created' $zipPath"

REM Deploy to Factorio mods folder
copy /Y "!zipname!" "!target!\!zipname!"

REM Clean up temporary folder
rmdir /s /q "!foldername!"

echo.
echo Deployment complete:
echo   Factorio mods: !target!\!zipname!
echo   Portal upload: !zipname!
pause
endlocal
