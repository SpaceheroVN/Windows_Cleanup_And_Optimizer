@echo off
setlocal enabledelayedexpansion
title Windows Cleanup ^& Optimizer v6.0.1 - Ultimate Toolkit

:: =====================================================================
::                            CONFIGURATION
:: =====================================================================
set "VERSION=6.0.1"
set "TOOLNAME=Windows Cleanup & Optimizer"
set "BASE_DIR=%LocalAppData%\WCaO_Toolkit"
set "LOG_RETENTION_DAYS=7"
set "DEFAULT_EXPERT_MODE=0"

:: --- Generate Escape Character for ANSI Colors ---
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set ESC=%%b
set "cBLU=%ESC%[94m"
set "cGRE=%ESC%[92m"
set "cYEL=%ESC%[93m"
set "cRED=%ESC%[91m"
set "cCYA=%ESC%[96m"
set "cMAG=%ESC%[95m"
set "cWHI=%ESC%[97m"
set "cRES=%ESC%[0m"

:: =====================================================================
::                            INITIALIZATION
:: =====================================================================
set "EXPERT_MODE=%DEFAULT_EXPERT_MODE%"
set "TMP_LOGFILE=%BASE_DIR%\Actions.tmp"
set "ERROR_LOGFILE=%BASE_DIR%\Errors.log"
set "UNDO_LOG=%BASE_DIR%\RenameUndo.txt"

:: Create working directory
if not exist "%BASE_DIR%" mkdir "%BASE_DIR%" >nul 2>&1
if not exist "%BASE_DIR%\" (
    echo %cRED%[!] CRITICAL: Cannot create working dir.%cRES% & pause & exit /b
)

:: Manage logs
if exist "%TMP_LOGFILE%" del "%TMP_LOGFILE%" >nul 2>&1
call :CreateNewTempLog
forfiles /p "%BASE_DIR%" /m "Log_*.txt" /d -%LOG_RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1

:: Privilege check
set "IS_ADMIN=0"
>nul 2>&1 net session && set "IS_ADMIN=1"
set "OS_DRIVE=%SystemDrive%"
if not defined OS_DRIVE set "OS_DRIVE=C:"

:: =====================================================================
::                              MAIN MENU
:: =====================================================================
:main_menu
cls
call :DrawBox "%cCYA%%TOOLNAME% - v%VERSION%%cRES%"

set "exp_stat=%cRES%Off" & if "!EXPERT_MODE!"=="1" set "exp_stat=%cRED%On%cRES%"
set "adm_stat=%cRED%NO (Limited)%cRES%" & if "!IS_ADMIN!"=="1" set "adm_stat=%cGRE%YES (Full)%cRES%"

echo.
echo  %cWHI%System: %cYEL%%OS_DRIVE%%cWHI%  ^|  Admin: !adm_stat!%cWHI%  ^|  Expert: !exp_stat!
echo.
echo  %cGRE%[1]%cRES% Quick Cleanup
echo  %cRED%[2]%cRES% Deep Cleanup (Admin)
echo  %cCYA%[3]%cRES% System Optimization
echo  %cMAG%[4]%cRES% Advanced Tools
echo  %cBLU%[5]%cRES% System Utilities
echo  %cYEL%[6]%cRES% Screen ^& Power Tools
echo  %cGRE%[7]%cRES% Quick Rename Pro
echo  %cRED%[8]%cRES% Auto Maintenance (Admin)
echo  --------------------------------------
echo  %cYEL%[9]%cRES% Toolkit Options (Expert / Logs)
echo  %cWHI%[0]%cRES% Exit Toolkit
echo.
set "choice="
set /p "choice= %cCYA%Choose an option (0-9): %cRES%"

if "!choice!"=="1" call :QuickClean & goto main_menu
if "!choice!"=="2" call :DeepClean & goto main_menu
if "!choice!"=="3" call :SystemOptimizeMenu & goto main_menu
if "!choice!"=="4" call :AdvancedMenu & goto main_menu
if "!choice!"=="5" call :SystemUtilities & goto main_menu
if "!choice!"=="6" call :ScreenToolsMenu & goto main_menu
if "!choice!"=="7" call :QuickRename & goto main_menu
if "!choice!"=="8" call :AutoRun & goto main_menu
if "!choice!"=="9" call :Options & goto main_menu
if "!choice!"=="0" (if exist "%TMP_LOGFILE%" del "%TMP_LOGFILE%" >nul 2>&1 & exit /b)
goto main_menu

:: =====================================================================
::                         1. QUICK CLEANUP
:: =====================================================================
:QuickClean
cls & call :DrawBox "%cGRE%QUICK CLEANUP%cRES%" & echo.
call :CleanDir "%temp%" "User Temp folder"
call :CleanDir "%APPDATA%\Microsoft\Windows\Recent" "Recent shortcuts"

if "!IS_ADMIN!"=="1" (
    call :CleanDir "%SystemRoot%\Temp" "System Temp folder"
    call :CleanDir "%SystemRoot%\Prefetch" "Prefetch folder"
    echo  %cBLU%[+] Flushing DNS Cache...%cRES%
    ipconfig /flushdns >nul 2>&1
)

echo  %cBLU%[+] Emptying Recycle Bin...%cRES%
powershell.exe -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo      %cGRE%[OK] Recycle Bin cleared.%cRES% & call :LogAction "Recycle Bin cleared"
call :PauseToContinue & goto :EOF

:: =====================================================================
::                         2. DEEP CLEANUP
:: =====================================================================
:DeepClean
call :CheckAdmin || goto :EOF
cls & call :DrawBox "%cRED%DEEP CLEANUP%cRES%" & echo.

echo  %cBLU%[+] Running DISM RestoreHealth... (Please wait)%cRES%
Dism /Online /Cleanup-Image /RestoreHealth
set "rc=!errorlevel!"
if !rc! equ 0 (echo      %cGRE%[OK] DISM successful.%cRES% & call :LogAction "DISM OK") else (echo      %cRED%[ERROR] DISM Code !rc!%cRES% & call :LogAction "DISM ERR !rc!")

echo. & echo  %cBLU%[+] Running SFC /scannow...%cRES%
sfc /scannow
set "rc=!errorlevel!"
if !rc! equ 0 (echo      %cGRE%[OK] SFC successful.%cRES% & call :LogAction "SFC OK") else (echo      %cRED%[ERROR] SFC Code !rc!%cRES% & call :LogAction "SFC ERR !rc!")

echo. & echo  %cBLU%[+] Running Disk Cleanup...%cRES%
cleanmgr /autoclean >nul 2>&1
echo      %cGRE%[OK] Disk Cleanup executed.%cRES% & call :LogAction "cleanmgr executed"
call :PauseToContinue & goto :EOF

:: =====================================================================
::                      3. SYSTEM OPTIMIZATION
:: =====================================================================
:SystemOptimizeMenu
cls & call :DrawBox "%cCYA%SYSTEM OPTIMIZATION%cRES%" & echo.
echo  [1] Check Disk Integrity (Admin)
echo  [2] Defrag / Trim Drive (Admin)
echo  [3] Rebuild System Caches
echo  [4] Optimize Power Plan (Admin)
echo  [5] Optimize Visual Effects
echo  [6] Windows 11 Classic Context Menu (Toggle)
echo  [0] Back
echo.
set "opt="
set /p "opt= %cCYA%Choose option: %cRES%"

if "!opt!"=="1" (call :CheckAdmin && (cls & call :DrawBox "%cCYA%CHECK DISK%cRES%" & echo. & chkdsk %OS_DRIVE% /scan & pause))
if "!opt!"=="2" (call :CheckAdmin && (cls & call :DrawBox "%cCYA%DEFRAG / TRIM%cRES%" & echo. & defrag %OS_DRIVE% /O /L & pause))
if "!opt!"=="3" (
    cls & call :DrawBox "%cCYA%REBUILD CACHES%cRES%" & echo.
    echo  %cBLU%[+] Rebuilding icon ^& thumbnail caches...%cRES%
    taskkill /f /im explorer.exe >nul 2>&1 & timeout /t 1 >nul
    del /a /f /q "%localappdata%\IconCache.db" >nul 2>&1
    del /a /f /q "%localappdata%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
    start "" explorer.exe & call :LogAction "Caches rebuilt"
    if "!IS_ADMIN!"=="1" (sc query "WSearch" >nul 2>&1 && (net stop "WSearch" >nul 2>&1 & net start "WSearch" >nul 2>&1 & echo      %cGRE%[OK] WSearch restarted.%cRES%))
    echo  %cGRE%[+] Done.%cRES% & pause
)
if "!opt!"=="4" (call :CheckAdmin && call :SetPowerPlan)
if "!opt!"=="5" (call :SetVisualEffects)
if "!opt!"=="6" (call :ToggleContextMenu)
if "!opt!"=="0" (goto :EOF)
goto SystemOptimizeMenu

:SetPowerPlan
cls & call :DrawBox "OPTIMIZE POWER PLAN" & echo.
powercfg /list & echo -----------------------------------
echo  [1] Add Plan  [2] Remove Plan  [3] Set Plan  [4] Default  [0] Back & echo.
set "pp=" & set /p "pp= Choose: "
if "!pp!"=="1" (echo [1] Ultimate [2] High [3] Balanced [4] Saver & set /p "add=Add: " & if "!add!"=="1" powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61)
if "!pp!"=="2" (set /p "del_guid= GUID to remove: " & powercfg /delete !del_guid!)
if "!pp!"=="3" (set /p "set_guid= GUID to set: " & powercfg /s !set_guid!)
if "!pp!"=="4" powercfg /restoredefaultschemes
if "!pp!"=="0" goto :EOF
pause & goto SetPowerPlan

:SetVisualEffects
cls & call :DrawBox "VISUAL EFFECTS" & echo.
echo  [1] Best Performance  [2] Custom (Peek+Smooth Fonts)  [3] Default  [0] Back & echo.
set "ve=" & set /p "ve= Choose: "
if "!ve!"=="1" (reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 2 /f >nul & echo %cGRE%[+] Done. Reboot needed.%cRES%)
if "!ve!"=="2" (reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 3 /f >nul & echo %cGRE%[+] Done. Reboot needed.%cRES%)
if "!ve!"=="3" (reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 0 /f >nul & echo %cGRE%[+] Restored Default.%cRES%)
if "!ve!"=="0" goto :EOF
pause & goto SetVisualEffects

:ToggleContextMenu
cls & call :DrawBox "WIN 11 CONTEXT MENU" & echo.
echo  [1] Enable Classic Menu (Win 10 Style)
echo  [2] Restore Default Menu (Win 11 Style)
echo  [0] Back & echo.
set "cm=" & set /p "cm= Choose: "
if "!cm!"=="1" (reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve >nul & echo %cGRE%[+] Classic Menu Enabled. Reboot Explorer to see changes.%cRES%)
if "!cm!"=="2" (reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >nul 2>&1 & echo %cGRE%[+] Default Menu Restored. Reboot Explorer to see changes.%cRES%)
pause & goto :EOF

:: =====================================================================
::                       4. ADVANCED TOOLS
:: =====================================================================
:AdvancedMenu
cls & call :DrawBox "%cMAG%ADVANCED TOOLS%cRES%" & echo.
echo  [1] Clear Update Cache (Admin)
echo  [2] Uninstall Office Key (Admin)
echo  [3] Remove Windows.old (Admin+Expert)
echo  [4] Manage Pagefile/Hibernation (Admin+Expert)
echo  [5] Network Reset ^& Flush DNS (Admin)
echo  [6] Create Restore Point (Admin)
echo  [0] Back
echo.
set "adv="
set /p "adv= %cMAG%Choose option: %cRES%"

if "!adv!"=="1" (call :CheckAdmin && call :ClearWinUpdate & pause)
if "!adv!"=="2" (call :CheckAdmin && call :UninstallOfficeKey & pause)
if "!adv!"=="3" (call :CheckAdmin && if "!EXPERT_MODE!"=="1" (call :RemoveWindowsOld & pause) else (echo %cRED%[-] Expert Mode required.%cRES% & pause))
if "!adv!"=="4" (call :CheckAdmin && if "!EXPERT_MODE!"=="1" (call :PagefileMenu) else (echo %cRED%[-] Expert Mode required.%cRES% & pause))
if "!adv!"=="5" (call :CheckAdmin && call :NetReset & pause)
if "!adv!"=="6" (call :CheckAdmin && call :CreateRestorePoint & pause)
if "!adv!"=="0" (goto :EOF)
goto AdvancedMenu

:ClearWinUpdate
cls & echo %cBLU%[+] Stopping services...%cRES%
sc stop wuauserv >nul 2>&1 & sc stop bits >nul 2>&1 & sc stop cryptsvc >nul 2>&1
if exist "%windir%\SoftwareDistribution" rd /s /q "%windir%\SoftwareDistribution" >nul 2>&1
if exist "%windir%\System32\catroot2" rd /s /q "%windir%\System32\catroot2" >nul 2>&1
echo %cBLU%[+] Restarting services...%cRES%
net start cryptsvc >nul 2>&1 & net start bits >nul 2>&1 & net start wuauserv >nul 2>&1
echo %cGRE%[+] Update Cache Cleared.%cRES% & goto :EOF

:UninstallOfficeKey
cls & if exist "C:\Program Files\Microsoft Office\Office16\ospp.vbs" (cd /d "C:\Program Files\Microsoft Office\Office16") else (if exist "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs" (cd /d "C:\Program Files (x86)\Microsoft Office\Office16") else (echo %cRED%[-] Office 2016 ospp.vbs not found.%cRES% & exit /b))
cscript ospp.vbs /dstatus
goto :EOF

:RemoveWindowsOld
cls & set "WINOLD=%OS_DRIVE%\Windows.old"
if exist "%WINOLD%" (
    echo %cYEL%WARNING: Irreversible deletion of Windows.old.%cRES% & set /p "confirm=Type 'YES': "
    if /i "!confirm!"=="YES" (
        takeown /F "%WINOLD%" /R /D Y >nul & icacls "%WINOLD%" /grant *S-1-5-32-544:F /T >nul
        rd /s /q "%WINOLD%" & echo %cGRE%[+] Done.%cRES%
    )
) else (echo %cYEL%[-] Not found.%cRES%)
goto :EOF

:PagefileMenu
cls & echo [1] Disable Auto Pagefile  [2] Disable Hibernation  [0] Back
set "pf=" & set /p "pf=Choose: "
if "!pf!"=="1" (wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False >nul & echo %cGRE%[+] Disabled. Reboot needed.%cRES% & pause)
if "!pf!"=="2" (powercfg -h off & echo %cGRE%[+] Hibernation disabled.%cRES% & pause)
if "!pf!"=="0" goto :EOF
goto PagefileMenu

:NetReset
cls & ipconfig /flushdns >nul & netsh winsock reset >nul & netsh int ip reset >nul
echo %cGRE%[+] Network Reset Complete. Reboot recommended.%cRES% & goto :EOF

:CreateRestorePoint
cls & powershell -Command "Enable-ComputerRestore -Drive '%OS_DRIVE%'" >nul 2>&1
powershell -Command "Checkpoint-Computer -Description 'ProToolkit_Backup' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel% equ 0 (echo %cGRE%[OK] Created.%cRES%) else (echo %cRED%[ERROR] Failed.%cRES%)
goto :EOF

:: =====================================================================
::                      5. SYSTEM UTILITIES
:: =====================================================================
:SystemUtilities
cls & call :DrawBox "%cBLU%SYSTEM UTILITIES%cRES%" & echo.
echo  [1] Show Advanced System Info
echo  [2] Restart Windows Explorer (Fix UI Glitches)
echo  [3] Kill 'Not Responding' Tasks
echo  [4] Update All Installed Software (Winget)
echo  [0] Back
echo.
set "util="
set /p "util= %cBLU%Choose option: %cRES%"

if "!util!"=="1" goto SysUtil1
if "!util!"=="2" goto SysUtil2
if "!util!"=="3" goto SysUtil3
if "!util!"=="4" goto SysUtil4
if "!util!"=="0" exit /b
goto SystemUtilities

:SysUtil1
cls & call :DrawBox "ADVANCED SYSTEM INFO" & echo.
echo  %cCYA%[+] Fetching detailed hardware information... (Please wait)%cRES%
echo.
powershell -NoProfile -Command "$c='Cyan'; $w='White'; Write-Host ' [SYSTEM AND OS]' -F $c; $os=Get-CimInstance Win32_OperatingSystem; $cs=Get-CimInstance Win32_ComputerSystem; $bios=Get-CimInstance Win32_BIOS; Write-Host ('   OS Name      : '+$os.Caption) -F $w; Write-Host ('   OS Version   : '+$os.Version+' ('+$os.OSArchitecture+')') -F $w; Write-Host ('   System Name  : '+$cs.Name) -F $w; Write-Host ('   System Type  : '+$cs.SystemType) -F $w; Write-Host ('   BIOS Version : '+$bios.Name) -F $w; Write-Host ''; Write-Host ' [PROCESSOR AND BOARD]' -F $c; $cpu=Get-CimInstance Win32_Processor; Write-Host ('   CPU          : '+$cpu.Name.Trim()) -F $w; Write-Host ('   Cores/Threads: '+$cpu.NumberOfCores+' Cores, '+$cpu.NumberOfLogicalProcessors+' Threads') -F $w; $mb=Get-CimInstance Win32_BaseBoard; Write-Host ('   Motherboard  : '+$mb.Manufacturer+' '+$mb.Product) -F $w; Write-Host ''; Write-Host ' [MEMORY AND GRAPHICS]' -F $c; $rT=[math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum/1GB, 2); $rA=[math]::Round($os.FreePhysicalMemory/1024, 2); Write-Host ('   RAM Total    : '+$rT+' GB') -F $w; Write-Host ('   RAM Available: '+$rA+' GB') -F $w; foreach($g in @(Get-CimInstance Win32_VideoController)){Write-Host ('   GPU          : '+$g.Caption) -F $w}; Write-Host ''; Write-Host ' [STORAGE]' -F $c; foreach($d in @(Get-CimInstance Win32_DiskDrive)){Write-Host ('   Disk         : '+$d.Model+' ('+[math]::Round($d.Size/1GB, 2)+' GB)') -F $w}"
echo. & pause
goto SystemUtilities

:SysUtil2
echo %cBLU%[+] Restarting Explorer...%cRES%
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo %cGRE%[+] Done.%cRES% & pause
goto SystemUtilities

:SysUtil3
echo %cBLU%[+] Terminating frozen applications...%cRES%
taskkill.exe /F /FI "status eq NOT RESPONDING"
echo %cGRE%[+] Done.%cRES% & pause
goto SystemUtilities

:SysUtil4
cls & echo %cCYA%[+] Checking for software updates via Winget...%cRES%
winget upgrade --all --include-unknown
echo. & echo %cGRE%[+] Update process finished.%cRES% & pause
goto SystemUtilities


:: =====================================================================
::                     6. SCREEN & POWER TOOLS
:: =====================================================================
:ScreenToolsMenu
cls & call :DrawBox "%cYEL%SCREEN AND POWER TOOLS%cRES%" & echo.
echo  [1] Turn Off Screen Immediately
echo  [2] Create "Turn Off Screen.bat" on Desktop
echo  [0] Back
echo.
set "scr_choice="
set /p "scr_choice= %cYEL%Choose option: %cRES%"

if "!scr_choice!"=="1" goto ScrOffNow
if "!scr_choice!"=="2" goto ScrOffBat
if "!scr_choice!"=="0" exit /b
goto ScreenToolsMenu

:ScrOffNow
echo  Turning off screen...
call :LogAction "Screen turned off via script"
powershell -Command "(Add-Type '[DllImport(\"user32.dll\")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)"
goto ScreenToolsMenu

:ScrOffBat
set "bat_path=%USERPROFILE%\Desktop\Turn Off Screen.bat"
echo @echo off> "!bat_path!"
echo title Turn Off Screen>> "!bat_path!"
echo cls ^& color 0B>> "!bat_path!"
echo setlocal enabledelayedexpansion>> "!bat_path!"
echo for /l %%%%i in (3,-1,1) do (>> "!bat_path!"
echo     cls ^& echo Turning off in %%%%i seconds...>> "!bat_path!"
echo     timeout /t 1 ^>nul>> "!bat_path!"
echo )>> "!bat_path!"
echo echo Turning off now...>> "!bat_path!"
echo powershell -Command "(Add-Type '[DllImport(\"user32.dll\")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)">> "!bat_path!"
echo exit /b>> "!bat_path!"
echo  %cGRE%[+] Created: "!bat_path!"%cRES%
call :LogAction "Generated Turn Off Screen.bat on Desktop"
call :PauseToContinue
goto ScreenToolsMenu

:: =====================================================================
::                       7. QUICK RENAME PRO
:: =====================================================================
:QuickRename
if not defined mode1 set "mode1=File"
if not defined mode2_code set "mode2_code=1.1"
if not defined mode2_desc set "mode2_desc=Extract: K(x).re -^> x.re"
set "remove_x=" & set "rep_a=" & set "rep_b="

:QuickRenameUI
cls & call :DrawBox "%cGRE%QUICK RENAME PRO%cRES%" & echo.
echo  %cBLU%[+] Target Type: %mode1%%cRES%
echo  %cBLU%[+] Active Mode: %mode2_code% - %mode2_desc%%cRES%
if defined remove_x echo  %cBLU%[+] Param [x]: !remove_x!%cRES%
if defined rep_a echo  %cBLU%[+] Replace: '!rep_a!' with '!rep_b!'%cRES%
echo.
echo  %cGRE%--- CONFIGURATION ---%cRES%
echo  [0] Back to Main Menu
echo  %cYEL%[1] FILE Modes:%cRES%
echo      %cCYA%[1.1] Extract Brackets   %cRES%Ex: Report(2023).txt -^> 2023.txt
echo      %cCYA%[1.2] Sequential Series  %cRES%Ex: Folder -^> Folder - 1.jpg, Folder - 2.jpg
echo      %cCYA%[1.3] Remove Suffix (x)  %cRES%Ex: Image_copy.png -^> Image.png
echo      %cCYA%[1.4] Replace String     %cRES%Ex: A -^> B (Replace words)
echo  %cYEL%[2] FOLDER Modes:%cRES%
echo      %cCYA%[2.1] Extract Brackets   %cRES%Ex: Docs(Secret) -^> Secret
echo      %cCYA%[2.2] Remove Suffix (x)  %cRES%Ex: Backup_old -^> Backup
echo  %cYEL%[3] ACTIONS:%cRES%
echo      [3.1] Clear Output Screen
echo      [3.2] %cYEL%Undo Last Rename Batch%cRES%
echo.

:SubQuickRenameLoop
set "target_input="
set /p "target_input=%cYEL% Drag folder here, or type mode (ex: 1.2): %cRES%"

if "!target_input!"=="" goto SubQuickRenameLoop
if "!target_input!"=="0" goto :EOF
if "!target_input!"=="1" (set "mode1=File" & set "mode2_code=1.1" & set "mode2_desc=Extract: K(x).re -^> x.re" & goto QuickRenameUI)
if "!target_input!"=="1.1" (set "mode1=File" & set "mode2_code=1.1" & set "mode2_desc=Extract: K(x).re -^> x.re" & goto QuickRenameUI)
if "!target_input!"=="1.2" (set "mode1=File" & set "mode2_code=1.2" & set "mode2_desc=Sequential: Folder x -^> x - 1.re" & goto QuickRenameUI)
if "!target_input!"=="1.3" (set "mode1=File" & set "mode2_code=1.3" & set "mode2_desc=Remove Suffix: K[x].re -^> K.re" & set /p "remove_x= Enter exact suffix to remove [x]: " & goto QuickRenameUI)
if "!target_input!"=="1.4" (set "mode1=File" & set "mode2_code=1.4" & set "mode2_desc=Replace String A with B" & set /p "rep_a= String to find [A]: " & set /p "rep_b= Replace with [B]: " & goto QuickRenameUI)
if "!target_input!"=="2" (set "mode1=Folder" & set "mode2_code=2.1" & set "mode2_desc=Extract: K(x) -^> x" & goto QuickRenameUI)
if "!target_input!"=="2.1" (set "mode1=Folder" & set "mode2_code=2.1" & set "mode2_desc=Extract: K(x) -^> x" & goto QuickRenameUI)
if "!target_input!"=="2.2" (set "mode1=Folder" & set "mode2_code=2.2" & set "mode2_desc=Remove Suffix: K[x] -^> K" & set /p "remove_x= Enter exact suffix to remove [x]: " & goto QuickRenameUI)
if "!target_input!"=="3" goto QuickRenameUI
if "!target_input!"=="3.1" goto QuickRenameUI

:: Undo logic
if "!target_input!"=="3.2" (
    if not exist "!UNDO_LOG!" (echo  %cRED%[-] Nothing to undo.%cRES% & goto SubQuickRenameLoop)
    echo  %cBLU%[+] Undoing last rename batch...%cRES%
    powershell -NoProfile -Command "$log = $env:UNDO_LOG; if (Test-Path $log) { $lines = @(Get-Content $log); $idx = -1; for ($i = $lines.Count - 1; $i -ge 0; $i--) { if ($lines[$i] -eq '---BATCH_START---') { $idx = $i; break } }; if ($idx -ne -1) { $b = @(); if ($idx -lt $lines.Count - 1) { $b = @($lines[($idx + 1)..($lines.Count - 1)]) }; [array]::Reverse($b); foreach ($l in $b) { $p = $l -split '\|'; if ($p.Length -eq 3) { $fp = Join-Path $p[0] $p[1]; if (Test-Path -LiteralPath $fp) { try { Rename-Item -LiteralPath $fp -NewName $p[2] -Force -ErrorAction Stop; Write-Host ('  [UNDO OK] ' + $p[1] + ' -> ' + $p[2]) -ForegroundColor Yellow } catch { Write-Host ('  [-] UNDO FAILED: ' + $p[1] + ' (Locked)') -ForegroundColor Red } } else { Write-Host ('  [-] NOT FOUND: ' + $fp) -ForegroundColor Red } } }; if ($idx -gt 0) { Set-Content -Path $log -Value $lines[0..($idx - 1)] -Force } else { Remove-Item $log -Force } } else { Write-Host '  [-] No recent actions to undo.' -ForegroundColor Yellow; Remove-Item $log -Force } }"
    echo  %cGRE%[+] Undo complete!%cRES%
    goto SubQuickRenameLoop
)

set "target_dir=!target_input:"=!"
if not exist "!target_dir!\" (echo  %cRED%[-] Path does not exist or invalid command.%cRES% & goto SubQuickRenameLoop)

echo  %cBLU%[+] Processing mode %mode2_code% in: !target_dir!...%cRES%
>> "%UNDO_LOG%" echo ---BATCH_START---
if "%mode2_code%"=="1.1" powershell -NoProfile -Command "Get-ChildItem -LiteralPath $env:target_dir -File | Where-Object { $_.BaseName -match '^.*\((.*?)\)$' } | ForEach-Object { $nn = ($_.BaseName -replace '^.*\((.*?)\)$', '$1') + $_.Extension; $old = $_.Name; try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME] ' + $old + ' -> ' + $nn) }; Add-Content -Path $env:UNDO_LOG -Value ($_.DirectoryName + '|' + $nn + '|' + $old) } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red } }"
if "%mode2_code%"=="1.2" powershell -NoProfile -Command "$folder = Get-Item -LiteralPath $env:target_dir; $fName = $folder.Name; $files = Get-ChildItem -LiteralPath $folder.FullName -File | Sort-Object @{e={[regex]::Replace($_.BaseName, '\d+', [System.Text.RegularExpressions.MatchEvaluator]{param($m) $m.Value.PadLeft(10, '0')})}}; $temp = @(); foreach ($f in $files) { $tmp = $f.Name + '.tmp_ren'; try { Rename-Item -LiteralPath $f.FullName -NewName $tmp -Force -ErrorAction Stop; $temp += [PSCustomObject]@{ Old = $f.Name; Tmp = $tmp; Ext = $f.Extension } } catch { Write-Host ('  [-] SKIPPED: ' + $f.Name) -ForegroundColor Red } }; $i = 1; foreach ($t in $temp) { $nn = $fName + ' - ' + $i + $t.Ext; try { Rename-Item -LiteralPath (Join-Path $folder.FullName $t.Tmp) -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $t.Old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME] ' + $t.Old + ' -> ' + $nn) }; Add-Content -Path $env:UNDO_LOG -Value ($folder.FullName + '|' + $nn + '|' + $t.Old) } catch { Write-Host ('  [-] ERR: ' + $t.Old) -ForegroundColor Red }; $i++ }"
if "%mode2_code%"=="1.3" powershell -NoProfile -Command "$rx = [regex]::Escape($env:remove_x); Get-ChildItem -LiteralPath $env:target_dir -File | Where-Object { $_.BaseName -match ($rx + '$') } | ForEach-Object { $nn = ($_.BaseName -replace ($rx + '$'), '') + $_.Extension; $old = $_.Name; try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME] ' + $old + ' -> ' + $nn) }; Add-Content -Path $env:UNDO_LOG -Value ($_.DirectoryName + '|' + $nn + '|' + $old) } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red } }"
if "%mode2_code%"=="1.4" powershell -NoProfile -Command "$ra = [regex]::Escape($env:rep_a); $rb = $env:rep_b; Get-ChildItem -LiteralPath $env:target_dir -File | Where-Object { $_.Name -match $ra } | ForEach-Object { $nn = $_.Name -replace $ra, $rb; $old = $_.Name; try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME] ' + $old + ' -> ' + $nn) }; Add-Content -Path $env:UNDO_LOG -Value ($_.DirectoryName + '|' + $nn + '|' + $old) } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red } }"
if "%mode2_code%"=="2.1" powershell -NoProfile -Command "Get-ChildItem -LiteralPath $env:target_dir -Directory | Where-Object { $_.Name -match '^.*\((.*?)\)$' } | ForEach-Object { $nn = $_.Name -replace '^.*\((.*?)\)$', '$1'; $old = $_.Name; try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME FOLDER] ' + $old + ' -> ' + $nn) }; Add-Content -Path $env:UNDO_LOG -Value ($_.Parent.FullName + '|' + $nn + '|' + $old) } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red } }"
if "%mode2_code%"=="2.2" powershell -NoProfile -Command "$rx = [regex]::Escape($env:remove_x); Get-ChildItem -LiteralPath $env:target_dir -Directory | Where-Object { $_.Name -match ($rx + '$') } | ForEach-Object { $nn = $_.Name -replace ($rx + '$'), ''; $old = $_.Name; try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; if ($env:TMP_LOGFILE) { Add-Content -Path $env:TMP_LOGFILE -Value ('[' + (Get-Date -Format 'HH:mm:ss.ff') + '] [RENAME FOLDER] ' + $old + ' -> ' + $nn) }; Add-Content -Path $env:UNDO_LOG -Value ($_.Parent.FullName + '|' + $nn + '|' + $old) } catch { Write-Host ('  [-] SKIPPED: ' + $old + ' (Locked)') -ForegroundColor Red } }"

echo  %cGRE%[+] Done^^!%cRES%
goto SubQuickRenameLoop

:: =====================================================================
::                   8. AUTO MAINTENANCE (ADMIN)
:: =====================================================================
:AutoRun
call :CheckAdmin || goto :EOF
cls & call :DrawBox "%cRED%AUTO MAINTENANCE%cRES%"
set /p "confirm=%cYEL%Type 'AUTO' to start: %cRES%"
if /i not "!confirm!"=="AUTO" goto :EOF
call :QuickClean & call :DeepClean & call :ClearWinUpdate
echo %cGRE%[+] FULL MAINTENANCE COMPLETE.%cRES%
set /p "rebootq=Reboot now? (Y/N): "
if /i "!rebootq!"=="Y" shutdown /r /t 10
goto :EOF

:: =====================================================================
::                     9. TOOLKIT OPTIONS
:: =====================================================================
:Options
cls & call :DrawBox "%cYEL%OPTIONS & LOGS%cRES%" & echo.
echo  [1] Toggle Expert Mode (Show hidden/dangerous options)
echo  [2] Export Action Report
echo  [0] Back
echo.
set "opt_c="
set /p "opt_c= %cYEL%Choose option: %cRES%"

if "!opt_c!"=="1" (if "!EXPERT_MODE!"=="0" (set "EXPERT_MODE=1") else (set "EXPERT_MODE=0"))
if "!opt_c!"=="2" (
    if not exist "%TMP_LOGFILE%" (echo %cRED%[-] No actions to export.%cRES% & pause & goto :EOF)
    for /f "usebackq" %%i in (`powershell -Command "Get-Date -Format 'yyyyMMddHHmm'"`) do set "NOW=%%i"
    set "EXP=%BASE_DIR%\Log_!NOW!.txt"
    copy "%TMP_LOGFILE%" "!EXP!" >nul
    echo %cGRE%[+] Exported: !EXP!%cRES% & start "" "%BASE_DIR%" & pause
)
goto :EOF

:: =====================================================================
::                       HELPER FUNCTIONS
:: =====================================================================
:CheckAdmin
:: Ensure script has elevated privileges
if "!IS_ADMIN!"=="0" (
    echo.
    echo  %cRED%[!] This feature requires Administrator privileges.%cRES%
    echo      %cYEL%Please restart the tool as Admin to use this.%cRES%
    pause & exit /b 1
)
exit /b 0

:CreateNewTempLog
:: Start a fresh temp log
>> "%TMP_LOGFILE%" echo --- Started: %date% %time% ---
goto :EOF

:CleanDir
:: Clean a target directory safely
if exist "%~1" (
    pushd "%~1" >nul 2>&1 && (del /f /s /q * >nul 2>&1 & for /d %%D in (*) do rd /s /q "%%D" >nul 2>&1 & popd & echo  %cGRE%[OK] %~2 cleaned.%cRES% & call :LogAction "%~2 cleaned") || call :LogError "Failed to clean %~2"
)
goto :EOF

:LogAction
:: Append success action to log
>> "%TMP_LOGFILE%" echo [%time%] %~1
goto :EOF

:LogError
:: Append error to log
>> "%ERROR_LOGFILE%" echo [%date% %time%] %~1
goto :EOF

:DrawBox
:: Draw ASCII UI box dynamically
setlocal & set "text=%~1"
:: Remove ANSI codes for length calculation
set "cleanText=!text:%cBLU%=!"
set "cleanText=!cleanText:%cGRE%=!"
set "cleanText=!cleanText:%cYEL%=!"
set "cleanText=!cleanText:%cRED%=!"
set "cleanText=!cleanText:%cCYA%=!"
set "cleanText=!cleanText:%cMAG%=!"
set "cleanText=!cleanText:%cWHI%=!"
set "cleanText=!cleanText:%cRES%=!"

set "len=0"
:len_loop
if defined cleanText (set "cleanText=!cleanText:~1!" & set /a len+=1 & goto len_loop)
set "padding=" & for /l %%A in (1,1,%len%) do set "padding=!padding!="
echo. & echo   +-%padding%-+ & echo   ^| !text! ^| & echo   +-%padding%-+ & endlocal
goto :EOF

:PauseToContinue
:: Standard UI pause
echo. & echo  %cYEL%==========================================%cRES%
echo  %cWHI%DONE! Press any key to return...%cRES%
echo  %cYEL%==========================================%cRES% & pause >nul & goto :EOF