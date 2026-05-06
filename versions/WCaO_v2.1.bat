@echo off
chcp 65001>nul
setlocal enabledelayedexpansion

:: ============================
:: CẤU HÌNH MÀU CHỮ
:: ============================
set "COLOR_ERROR=C"
set "COLOR_MENU=B"
set "COLOR_ACTION=E"
set "COLOR_CLEAN=A"
set "COLOR_END=7"

:: ============================
:: TIÊU ĐỀ SCRIPT
:: ============================
title Windows Cleanup and Optimizer v2.1

:: ============================
:: KIỂM TRA QUYỀN ADMIN
:: ============================
powershell -Command "if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) { exit 1 }"
if %errorlevel% neq 0 (
    cls
    color 0%COLOR_ERROR%
    call :DrawBox "ERROR: SCRIPT MUST BE RUN AS ADMINISTRATOR"
    echo.
    echo Please right-click the file and choose 'Run as administrator'.
    echo.
    pause
    exit /b
)

:: ============================
:: MENU CHÍNH
:: ============================
:main_menu
cls
color 0%COLOR_MENU%
call :DrawBox "WINDOWS CLEANUP & OPTIMIZER"
echo.
echo Select a disk to clean and optimize:
powershell -Command "Get-PhysicalDisk | Format-Table -AutoSize @{L='ID';E={$_.DeviceID}}, @{L='Name';E={$_.FriendlyName}}, @{L='Type';E={$_.MediaType}}"
echo.
set /p "DRIVE_ID= > Enter Disk ID (e.g., 0): "
if not defined DRIVE_ID (
    echo Invalid input. Try again.
    timeout /t 2 >nul
    goto main_menu
)

for /f "tokens=*" %%f in ('powershell -Command "(Get-PhysicalDisk -DeviceID %DRIVE_ID%).MediaType"') do set "DRIVE_TYPE=%%f"
for /f "tokens=*" %%g in ('powershell -Command "(Get-Partition -DiskNumber %DRIVE_ID% | Where-Object IsBoot).DriveLetter"') do set "DRIVE_LETTER=%%g"

if not defined DRIVE_LETTER (
    cls
    color 0%COLOR_ERROR%
    call :DrawBox "ERROR: WINDOWS DRIVE NOT FOUND"
    echo.
    echo Selected disk does not contain the OS.
    pause
    goto main_menu
)

:: ============================
:: MENU HÀNH ĐỘNG
:: ============================
:action_menu
cls
color 0%COLOR_ACTION%
call :DrawBox "SELECTED DRIVE: %DRIVE_LETTER%: (%DRIVE_TYPE%)"
echo.
echo [1] Quick Cleanup
echo [2] Deep Cleanup
echo [3] Back
echo.
set /p "choice= > Choose (1, 2 or 3): "
if "%choice%"=="1" call :QuickClean & goto end_script
if "%choice%"=="2" call :DeepClean & goto end_script
if "%choice%"=="3" goto main_menu
goto action_menu

:: ============================
:: DỌN DẸP NHANH
:: ============================
:QuickClean
cls
color 0%COLOR_CLEAN%
call :DrawBox "QUICK CLEANUP ON [%DRIVE_LETTER%:]"
set /a COUNT=0

for /f %%f in ('dir /a /b /s "%temp%" 2^>nul') do set /a COUNT+=1
rd /s /q "%temp%" 2>nul
mkdir "%temp%"

for /f %%f in ('dir /a /b /s "%SystemRoot%\Temp" 2^>nul') do set /a COUNT+=1
rd /s /q "%SystemRoot%\Temp" 2>nul
mkdir "%SystemRoot%\Temp"

for /f %%f in ('dir /a /b /s "%SystemRoot%\Prefetch" 2^>nul') do set /a COUNT+=1
del /s /q "%SystemRoot%\Prefetch\*.*" >nul 2>&1

for /f %%f in ('dir /a /b /s "%APPDATA%\Microsoft\Windows\Recent" 2^>nul') do set /a COUNT+=1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*.*" >nul 2>&1

for /f %%f in ('dir /a /b /s "%DRIVE_LETTER%:\$Recycle.bin" 2^>nul') do set /a COUNT+=1
rd /s /q "%DRIVE_LETTER%:\$Recycle.bin" 2>nul

echo.
echo Total junk files removed: !COUNT!
goto :EOF

:: ============================
:: DỌN DẸP CHUYÊN SÂU
:: ============================
:DeepClean
cls
color 0%COLOR_CLEAN%
call :DrawBox "DEEP CLEANUP ON [%DRIVE_LETTER%:]"
set /a COUNT=0

sfc /scannow

if /i "%DRIVE_TYPE%"=="HDD" (
    defrag %DRIVE_LETTER%: /O
) else (
    echo SSD detected. Skipping defrag.
)

for /f %%f in ('dir /a /b /s "%APPDATA%\Microsoft\Windows\Recent" 2^>nul') do set /a COUNT+=1
del /f /q "%APPDATA%\Microsoft\Windows\Recent\*.*" >nul 2>&1

for /f %%f in ('dir /a /b /s "%DRIVE_LETTER%:\$Recycle.bin" 2^>nul') do set /a COUNT+=1
rd /s /q "%DRIVE_LETTER%:\$Recycle.bin" 2>nul

cleanmgr /d %DRIVE_LETTER%:

echo.
echo Total junk files removed: !COUNT!
goto :EOF

:: ============================
:: VẼ KHUNG TIÊU ĐỀ
:: ============================
:DrawBox
set "text= %~1 "
set "len=0"
for /l %%i in (0,1,255) do (
    set "char=!text:~%%i,1!"
    if "!char!"=="" goto :draw
    set /a len+=1
)
:draw
set "border="
for /l %%i in (1,1,%len%) do set "border=!border!=="
echo.
echo +!border!+
echo ^|!text!^|
echo +!border!+
goto :EOF

:: ============================
:: KẾT THÚC
:: ============================
:end_script
color 0%COLOR_END%
echo.
echo Press any key to exit...
pause >nul
exit
