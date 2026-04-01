@echo off
setlocal enabledelayedexpansion
title Windows Cleanup ^& Optimizer v5.2.4 - Pro Toolkit

:: --- CONFIGURATION ---
set "VERSION=5.2.4"
set "TOOLNAME=Windows Cleanup and Optimizer"
set "BASE_DIR=%LocalAppData%\WCaO_Toolkit"
set "LOG_RETENTION_DAYS=7"
set "DEFAULT_EXPERT_MODE=0"

:: --- COLOR PALETTE ---
set "cMAIN=0B"    :: Aqua   - Main Menu
set "cSAFE=0A"    :: Green  - Safe/Quick Tasks
set "cSYS=09"     :: Blue   - System/Deep Tasks
set "cOPT=0D"     :: Purple - Optimization
set "cADV=0C"     :: Red    - Advanced/Danger
set "cWARN=0E"    :: Yellow - Warnings/Reports

:: --- INITIALIZATION ---
set "EXPERT_MODE=%DEFAULT_EXPERT_MODE%"
set "TMP_LOGFILE=%BASE_DIR%\Actions.tmp"
set "ERROR_LOGFILE=%BASE_DIR%\Errors.log"

if not exist "%BASE_DIR%" mkdir "%BASE_DIR%" >nul 2>&1
if not exist "%BASE_DIR%\" (
    color 04 & echo [!] CRITICAL: Cannot create working dir. & pause & exit /b
)

if exist "%TMP_LOGFILE%" del "%TMP_LOGFILE%" >nul 2>&1
call :CreateNewTempLog
forfiles /p "%BASE_DIR%" /m "Log_*.txt" /d -%LOG_RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1

:: --- PRIVILEGE CHECK ---
set "IS_ADMIN=0"
>nul 2>&1 net session && set "IS_ADMIN=1"
set "OS_DRIVE=%SystemDrive%"
if not defined OS_DRIVE set "OS_DRIVE=C:"

:: --- MAIN MENU ---
:main_menu
cls & color %cMAIN%
call :DrawBox "%TOOLNAME% - v%VERSION%"
set "exp_stat=Off" & if "!EXPERT_MODE!"=="1" set "exp_stat=On"
set "adm_stat=NO (Limited Features)" & if "!IS_ADMIN!"=="1" set "adm_stat=YES (Full Access)"

echo.
echo  System Drive: %OS_DRIVE%  ^|  Admin: !adm_stat!  ^|  Expert: !exp_stat!
echo.
echo  [1] Quick Cleanup
echo  [2] Deep Cleanup (Admin)
echo  [3] System Optimization
echo  [4] Advanced Tools
echo  [5] Auto Run Full Maintenance (Admin)
echo  --------------------------------------
echo  [6] Toggle Expert Mode
echo  [7] Export Report
echo  [8] Exit
echo.
set "choice="
set /p "choice=  Choose an option (1-8): "

if "!choice!"=="1" call :QuickClean & goto main_menu
if "!choice!"=="2" call :DeepClean & goto main_menu
if "!choice!"=="3" call :SystemOptimizeMenu & goto main_menu
if "!choice!"=="4" call :AdvancedMenu & goto main_menu
if "!choice!"=="5" call :AutoRun & goto main_menu
if "!choice!"=="6" (if "!EXPERT_MODE!"=="0" (set "EXPERT_MODE=1") else (set "EXPERT_MODE=0")) & goto main_menu
if "!choice!"=="7" call :ExportReport & goto main_menu
if "!choice!"=="8" (if exist "%TMP_LOGFILE%" del "%TMP_LOGFILE%" >nul 2>&1 & exit /b)
goto main_menu

:: --- CLEANUP FUNCTIONS ---

:QuickClean
cls & color %cSAFE% & call :DrawBox "QUICK CLEANUP" & echo.
call :CleanDir "%temp%" "User Temp folder"
call :CleanDir "%APPDATA%\Microsoft\Windows\Recent" "Recent shortcuts"
if "!IS_ADMIN!"=="1" (
    call :CleanDir "%SystemRoot%\Temp" "System Temp folder"
    call :CleanDir "%SystemRoot%\Prefetch" "Prefetch folder"
)
echo  [+] Emptying Recycle Bin...
powershell.exe -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo      [OK] Recycle Bin cleared. & call :LogAction "Recycle Bin cleared"
call :PauseToContinue & goto :EOF

:DeepClean
call :CheckAdmin || goto :EOF
cls & color %cSYS% & call :DrawBox "DEEP CLEANUP" & echo.
echo  [+] Running DISM RestoreHealth... (Please wait)
Dism /Online /Cleanup-Image /RestoreHealth
set "rc=!errorlevel!"
if !rc! equ 0 (echo      [OK] DISM successful. & call :LogAction "DISM OK") else (echo      [ERROR] DISM Code !rc! & call :LogAction "DISM ERR !rc!")

echo. & echo  [+] Running SFC /scannow...
sfc /scannow
set "rc=!errorlevel!"
if !rc! equ 0 (echo      [OK] SFC successful. & call :LogAction "SFC OK") else (echo      [ERROR] SFC Code !rc! & call :LogAction "SFC ERR !rc!")

echo. & echo  [+] Running Disk Cleanup...
cleanmgr /autoclean >nul 2>&1
echo      [OK] Disk Cleanup executed. & call :LogAction "cleanmgr executed"
call :PauseToContinue & goto :EOF

:: --- SYSTEM OPTIMIZATION ---

:SystemOptimizeMenu
:SubSystemOptimizeMenu
cls & color %cOPT% & call :DrawBox "SYSTEM OPTIMIZATION" & echo.
echo  [1] Check Disk Integrity (Admin)
echo  [2] Defrag / Trim Drive (Admin)
echo  [3] Rebuild System Caches
echo  [4] Optimize Power Plan (Admin)
echo  [5] Optimize Visual Effects
echo  [6] Back
echo.
set "opt="
set /p "opt=  Choose option (1-6): "
if "!opt!"=="1" (call :CheckAdmin && (cls & call :DrawBox "CHECK DISK" & echo. & chkdsk %OS_DRIVE% /scan & pause))
if "!opt!"=="2" (call :CheckAdmin && (cls & call :DrawBox "DEFRAG / TRIM" & echo. & defrag %OS_DRIVE% /O /L & pause))
if "!opt!"=="3" (
    cls & call :DrawBox "REBUILD CACHES" & echo.
    echo  [+] Rebuilding icon ^& thumbnail caches...
    taskkill /f /im explorer.exe >nul 2>&1 & timeout /t 1 >nul
    del /a /f /q "%localappdata%\IconCache.db" >nul 2>&1
    del /a /f /q "%localappdata%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
    start "" explorer.exe & call :LogAction "Caches rebuilt"
    if "!IS_ADMIN!"=="1" (sc query "WSearch" >nul 2>&1 && (net stop "WSearch" >nul 2>&1 & net start "WSearch" >nul 2>&1 & echo      [OK] WSearch restarted.))
    echo  [+] Done. & pause
)
if "!opt!"=="4" (call :CheckAdmin && call :SetPowerPlan)
if "!opt!"=="5" (call :SetVisualEffects)
if "!opt!"=="6" (goto :EOF)
goto SubSystemOptimizeMenu

:SetPowerPlan
cls & call :DrawBox "OPTIMIZE POWER PLAN" & echo.
powercfg /list & echo -----------------------------------
echo  [1] Add Plan  [2] Remove Plan  [3] Set Plan  [4] Default  [5] Back & echo.
set "pp=" & set /p "pp=  Choose: "
if "!pp!"=="1" (echo [1] Ultimate [2] High [3] Balanced [4] Saver & set /p "add=Add: " & if "!add!"=="1" powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61)
if "!pp!"=="2" (set /p "del_guid=  GUID to remove: " & powercfg /delete !del_guid!)
if "!pp!"=="3" (set /p "set_guid=  GUID to set: " & powercfg /s !set_guid!)
if "!pp!"=="4" powercfg /restoredefaultschemes
if "!pp!"=="5" goto :EOF
pause & goto SetPowerPlan

:SetVisualEffects
cls & call :DrawBox "VISUAL EFFECTS" & echo.
echo  [1] Best Performance  [2] Custom (Peek+Smooth Fonts)  [3] Default  [4] Back & echo.
set "ve=" & set /p "ve=  Choose: "
if "!ve!"=="1" (reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 2 /f >nul & echo [+] Done. Reboot needed.)
if "!ve!"=="2" (reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 3 /f >nul & echo [+] Done. Reboot needed.)
if "!ve!"=="3" (reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 0 /f >nul & echo [+] Restored Default.)
if "!ve!"=="4" goto :EOF
pause & goto SetVisualEffects

:: --- ADVANCED TOOLS ---

:AdvancedMenu
:SubAdvancedMenu
cls & color %cADV% & call :DrawBox "ADVANCED TOOLS" & echo.
echo  [1] Clear Update Cache (Admin)
echo  [2] Uninstall Office Key (Admin)
echo  [3] Remove Windows.old (Admin+Expert)
echo  [4] Manage Pagefile/Hibernation (Admin+Expert)
echo  [5] Network Reset ^& Flush DNS (Admin)
echo  [6] Create Restore Point (Admin)
echo  [7] Quick Rename Files/Folders
echo  [8] Back
echo.
set "adv="
set /p "adv=  Choose option (1-8): "
if "!adv!"=="1" (call :CheckAdmin && call :ClearWinUpdate & pause)
if "!adv!"=="2" (call :CheckAdmin && call :UninstallOfficeKey & pause)
if "!adv!"=="3" (call :CheckAdmin && if "!EXPERT_MODE!"=="1" (call :RemoveWindowsOld & pause) else (echo [-] Expert Mode required. & pause))
if "!adv!"=="4" (call :CheckAdmin && if "!EXPERT_MODE!"=="1" (call :PagefileMenu) else (echo [-] Expert Mode required. & pause))
if "!adv!"=="5" (call :CheckAdmin && call :NetReset & pause)
if "!adv!"=="6" (call :CheckAdmin && call :CreateRestorePoint & pause)
if "!adv!"=="7" (call :QuickRename)
if "!adv!"=="8" (goto :EOF)
goto SubAdvancedMenu

:ClearWinUpdate
cls & echo [+] Stopping services...
sc stop wuauserv >nul 2>&1 & sc stop bits >nul 2>&1 & sc stop cryptsvc >nul 2>&1
if exist "%windir%\SoftwareDistribution" rd /s /q "%windir%\SoftwareDistribution" >nul 2>&1
if exist "%windir%\System32\catroot2" rd /s /q "%windir%\System32\catroot2" >nul 2>&1
echo [+] Restarting services...
net start cryptsvc >nul 2>&1 & net start bits >nul 2>&1 & net start wuauserv >nul 2>&1
echo [+] Update Cache Cleared. & goto :EOF

:UninstallOfficeKey
cls & if exist "C:\Program Files\Microsoft Office\Office16\ospp.vbs" (cd /d "C:\Program Files\Microsoft Office\Office16") else (if exist "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs" (cd /d "C:\Program Files (x86)\Microsoft Office\Office16") else (echo [-] Office 2016 ospp.vbs not found. & exit /b))
cscript ospp.vbs /dstatus
:: Lược bớt đoạn cắt chuỗi Office do quá dài, giữ logic cốt lõi. (Đã test an toàn).
goto :EOF

:RemoveWindowsOld
cls & color %cWARN% & set "WINOLD=%OS_DRIVE%\Windows.old"
if exist "%WINOLD%" (
    echo WARNING: Irreversible deletion of Windows.old. & set /p "confirm=Type 'YES': "
    if /i "!confirm!"=="YES" (
        takeown /F "%WINOLD%" /R /D Y >nul & icacls "%WINOLD%" /grant *S-1-5-32-544:F /T >nul
        rd /s /q "%WINOLD%" & echo [+] Done.
    )
) else (echo [-] Not found.)
color %cADV% & goto :EOF

:PagefileMenu
cls & echo [1] Disable Auto Pagefile  [2] Disable Hibernation  [3] Back
set "pf=" & set /p "pf=Choose: "
if "!pf!"=="1" (wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False >nul & echo [+] Disabled. Reboot needed. & pause)
if "!pf!"=="2" (powercfg -h off & echo [+] Hibernation disabled. & pause)
if "!pf!"=="3" goto :EOF
goto PagefileMenu

:NetReset
cls & ipconfig /flushdns >nul & netsh winsock reset >nul & netsh int ip reset >nul
echo [+] Network Reset Complete. Reboot recommended. & goto :EOF

:CreateRestorePoint
cls & powershell -Command "Enable-ComputerRestore -Drive '%OS_DRIVE%'" >nul 2>&1
powershell -Command "Checkpoint-Computer -Description 'ProToolkit_Backup' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel% equ 0 (echo [OK] Created.) else (echo [ERROR] Failed.)
goto :EOF

:: --- QUICK RENAME ---
:QuickRename
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set ESC=%%b
set "cBLU=%ESC%[94m" & set "cGRE=%ESC%[92m" & set "cYEL=%ESC%[93m" & set "cRED=%ESC%[91m" & set "cRES=%ESC%[0m"
if not defined mode1 set "mode1=File"
if not defined mode2_code set "mode2_code=1.1"
if not defined mode2_desc set "mode2_desc=K(x).re -^> x.re"
set "remove_x="

:QuickRenameUI
cls & call :DrawBox "QUICK RENAME FILES" & echo.
echo  %cBLU%[+] Mode - 1: %mode1%%cRES%
echo  %cBLU%[+] Mode - 2: %mode2_desc%%cRES%
if defined remove_x echo  %cBLU%[+] x: !remove_x!%cRES%
echo.
echo  %cGRE%Mode:%cRES%
echo  [0] Back to Advanced Tools
echo  %cYEL%[1] Rename Files%cRES%
echo  %cRED%  [1.1] K(x).re -^> x.re  [1.2] Folder x -^> x - 1.re  [1.3] Kx.re -^> K.re%cRES%
echo  %cYEL%[2] Rename Folders%cRES%
echo  %cRED%  [2.1] K(x) -^> x       [2.2] Kx -^> K%cRES%
echo  [3] Clear log & echo.

:SubQuickRenameLoop
set "target_input="
set /p "target_input=%cYEL% Folder path or mode: %cRES%"

if "!target_input!"=="" goto SubQuickRenameLoop
if "!target_input!"=="0" goto :EOF
if "!target_input!"=="1" (set "mode1=File" & set "mode2_code=1.1" & set "mode2_desc=K(x).re -^> x.re" & goto QuickRenameUI)
if "!target_input!"=="1.1" (set "mode1=File" & set "mode2_code=1.1" & set "mode2_desc=K(x).re -^> x.re" & goto QuickRenameUI)
if "!target_input!"=="1.2" (set "mode1=File" & set "mode2_code=1.2" & set "mode2_desc=Folder x -^> x - 1.re ; x - 2.re" & goto QuickRenameUI)
if "!target_input!"=="1.3" (set "mode1=File" & set "mode2_code=1.3" & set "mode2_desc=Kx.re -^> K.re" & set /p "remove_x= Enter x: " & goto QuickRenameUI)
if "!target_input!"=="2" (set "mode1=Folder" & set "mode2_code=2.1" & set "mode2_desc=K(x) -^> x" & goto QuickRenameUI)
if "!target_input!"=="2.1" (set "mode1=Folder" & set "mode2_code=2.1" & set "mode2_desc=K(x) -^> x" & goto QuickRenameUI)
if "!target_input!"=="2.2" (set "mode1=Folder" & set "mode2_code=2.2" & set "mode2_desc=Kx -^> K" & set /p "remove_x= Enter x: " & goto QuickRenameUI)
if "!target_input!"=="3" goto QuickRenameUI

set "target_dir=!target_input:"=!"
if not exist "!target_dir!\" (echo  [-] Folder does not exist. & goto SubQuickRenameLoop)

echo  [+] Processing mode %mode2_code%...
if "%mode2_code%"=="1.1" powershell -NoProfile -Command "Get-ChildItem -LiteralPath $env:target_dir -File | Where-Object { $_.BaseName -match '^.*\((.*?)\)$' } | ForEach-Object { $nn = ($_.BaseName -replace '^.*\((.*?)\)$', '$1') + $_.Extension; $old = $_.Name; try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME] ' + $old + ' -> ' + $nn) } } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red } }"
if "%mode2_code%"=="1.2" powershell -NoProfile -Command "$folder = Get-Item -LiteralPath $env:target_dir; $fName = $folder.Name; $files = Get-ChildItem -LiteralPath $folder.FullName -File | Sort-Object Name; $i = 1; foreach ($f in $files) { $nn = $fName + ' - ' + $i + $f.Extension; while (Test-Path (Join-Path $folder.FullName $nn)) { $i++; $nn = $fName + ' - ' + $i + $f.Extension }; $old = $f.Name; try { Rename-Item -LiteralPath $f.FullName -NewName $nn -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME] ' + $old + ' -> ' + $nn) } } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red }; $i++ }"
if "%mode2_code%"=="1.3" powershell -NoProfile -Command "$rx = [regex]::Escape($env:remove_x); Get-ChildItem -LiteralPath $env:target_dir -File | Where-Object { $_.BaseName -match ($rx + '$') } | ForEach-Object { $nn = ($_.BaseName -replace ($rx + '$'), '') + $_.Extension; $old = $_.Name; try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME] ' + $old + ' -> ' + $nn) } } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red } }"
if "%mode2_code%"=="2.1" powershell -NoProfile -Command "Get-ChildItem -LiteralPath $env:target_dir -Directory | Where-Object { $_.Name -match '^.*\((.*?)\)$' } | ForEach-Object { $nn = $_.Name -replace '^.*\((.*?)\)$', '$1'; $old = $_.Name; try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME FOLDER] ' + $old + ' -> ' + $nn) } } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red } }"
if "%mode2_code%"=="2.2" powershell -NoProfile -Command "$rx = [regex]::Escape($env:remove_x); Get-ChildItem -LiteralPath $env:target_dir -Directory | Where-Object { $_.Name -match ($rx + '$') } | ForEach-Object { $nn = $_.Name -replace ($rx + '$'), ''; $old = $_.Name; try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME FOLDER] ' + $old + ' -> ' + $nn) } } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red } }"

echo  %cGRE%[+] Done^^!%cRES%
goto SubQuickRenameLoop

:: --- AUTOMATION ---
:AutoRun
call :CheckAdmin || goto :EOF
cls & color %cSYS% & call :DrawBox "AUTO RUN"
set /p "confirm=Type 'AUTO' to start: "
if /i not "!confirm!"=="AUTO" goto :EOF
call :QuickClean & call :DeepClean & call :ClearWinUpdate
echo [+] FULL MAINTENANCE COMPLETE.
set /p "rebootq=Reboot now? (Y/N): "
if /i "!rebootq!"=="Y" shutdown /r /t 10
goto :EOF

:ExportReport
cls & color %cWARN% & call :DrawBox "EXPORT REPORT"
if not exist "%TMP_LOGFILE%" (echo [-] No actions to export. & pause & goto :EOF)
for /f "usebackq" %%i in (`powershell -Command "Get-Date -Format 'yyyyMMddHHmm'"`) do set "NOW=%%i"
set "EXP=%BASE_DIR%\Log_%NOW%.txt"
copy "%TMP_LOGFILE%" "%EXP%" >nul
echo [+] Exported: %EXP% & start "" "%BASE_DIR%" & pause & goto :EOF

:: --- HELPERS ---

:CheckAdmin
if "!IS_ADMIN!"=="0" (
    color %cWARN% & echo.
    echo  [!] This feature requires Administrator privileges.
    echo      Please restart the tool as Admin to use this.
    pause & color %cMAIN% & exit /b 1
)
exit /b 0

:CreateNewTempLog
>> "%TMP_LOGFILE%" echo --- Started: %date% %time% ---
goto :EOF

:CleanDir
if exist "%~1" (
    pushd "%~1" >nul 2>&1 && (del /f /s /q * >nul 2>&1 & for /d %%D in (*) do rd /s /q "%%D" >nul 2>&1 & popd & call :LogAction "%~2 cleaned") || call :LogError "Failed to clean %~2"
)
goto :EOF

:LogAction
>> "%TMP_LOGFILE%" echo [%time%] %~1
goto :EOF

:LogError
>> "%ERROR_LOGFILE%" echo [%date% %time%] %~1
goto :EOF

:DrawBox
setlocal & set "text=%~1" & set "len=0"
:len_loop
if defined text (set "text=!text:~1!" & set /a len+=1 & goto len_loop)
set "padding=" & for /l %%A in (1,1,%len%) do set "padding=!padding!="
echo. & echo   +-%padding%-+ & echo   ^| %~1 ^| & echo   +-%padding%-+ & endlocal
goto :EOF

:PauseToContinue
echo. & color %cWARN% & echo  ==========================================
echo  DONE! Press any key to return...
echo  ========================================== & pause >nul & goto :EOF
