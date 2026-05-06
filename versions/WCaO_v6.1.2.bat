@echo off
setlocal enabledelayedexpansion
title Windows Cleanup ^& Optimizer v6.1.2 - Ultimate Toolkit

reg add "HKCU\Console" /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
cd /d "%~dp0"

:: =====================================================================
::                            CONFIGURATION
:: =====================================================================
set "VERSION=6.1.2.Optimized"
set "TOOLNAME=Windows Cleanup & Optimizer"
set "BASE_DIR=%LocalAppData%\WCaO_Toolkit"
set "LOG_RETENTION_DAYS=7"
set "DEFAULT_EXPERT_MODE=0"

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

if not exist "%BASE_DIR%" mkdir "%BASE_DIR%" >nul 2>&1
if not exist "%BASE_DIR%\" (
    echo %cRED%[!] CRITICAL: Cannot create working dir.%cRES% & pause & exit /b
)

if exist "%TMP_LOGFILE%" del "%TMP_LOGFILE%" >nul 2>&1
call :CreateNewTempLog
forfiles /p "%BASE_DIR%" /m "Log_*.txt" /d -%LOG_RETENTION_DAYS% /c "cmd /c del @path" >nul 2>&1

set "IS_ADMIN=0"
>nul 2>&1 net session && set "IS_ADMIN=1"
set "OS_DRIVE=%SystemDrive%"
if not defined OS_DRIVE set "OS_DRIVE=C:"

:: =====================================================================
::                               MAIN MENU
:: =====================================================================
:main_menu
call :LogNav "Main Menu"
cls
call :DrawBox "%TOOLNAME% - v%VERSION%" "%cCYA%"

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
call :LogInput "Main Menu Choice" "!choice!"

if "!choice!"=="1" call :QuickClean & goto main_menu
if "!choice!"=="2" call :DeepClean & goto main_menu
if "!choice!"=="3" goto SystemOptimizeMenu
if "!choice!"=="4" goto AdvancedMenu
if "!choice!"=="5" goto SystemUtilities
if "!choice!"=="6" goto ScreenToolsMenu
if "!choice!"=="7" goto QuickRename
if "!choice!"=="8" call :AutoRun & goto main_menu
if "!choice!"=="9" call :Options & goto main_menu
if "!choice!"=="0" (
    call :SummarizeLog
    if exist "%TMP_LOGFILE%" del "%TMP_LOGFILE%" >nul 2>&1 
    exit /b
)
goto main_menu

:: =====================================================================
::                         1. QUICK CLEANUP
:: =====================================================================
:QuickClean
call :LogNav "Quick Cleanup"
cls & call :DrawBox "QUICK CLEANUP" "%cGRE%" & echo.
call :CleanDir "%temp%" "User Temp folder"
call :CleanDir "%APPDATA%\Microsoft\Windows\Recent" "Recent shortcuts"

if "!IS_ADMIN!"=="1" (
    call :CleanDir "%SystemRoot%\Temp" "System Temp folder"
    call :CleanDir "%SystemRoot%\Prefetch" "Prefetch folder"
    echo  %cBLU%[+] Flushing DNS Cache...%cRES%
    call :RunAndLog ipconfig /flushdns
)

echo  %cBLU%[+] Emptying Recycle Bin...%cRES%
call :RunAndLog powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo      %cGRE%[OK] Recycle Bin cleared.%cRES%
call :PauseToContinue
goto :EOF

:: =====================================================================
::                         2. DEEP CLEANUP
:: =====================================================================
:DeepClean
call :CheckAdmin || goto :EOF
call :LogNav "Deep Cleanup"
cls & call :DrawBox "DEEP CLEANUP" "%cRED%" & echo.

echo  %cBLU%[+] Running DISM RestoreHealth... (Please wait)%cRES%
call :RunAndLog Dism /Online /Cleanup-Image /RestoreHealth
set "rc=!errorlevel!"
if !rc! equ 0 (echo      %cGRE%[OK] DISM successful.%cRES%) else (echo      %cRED%[ERROR] DISM Code !rc!%cRES%)

echo. & echo  %cBLU%[+] Running SFC /scannow...%cRES%
call :RunAndLog sfc /scannow
set "rc=!errorlevel!"
if !rc! equ 0 (echo      %cGRE%[OK] SFC successful.%cRES%) else (echo      %cRED%[ERROR] SFC Code !rc!%cRES%)

echo. & echo  %cBLU%[+] Running Disk Cleanup...%cRES%
call :RunAndLog cleanmgr /autoclean
echo      %cGRE%[OK] Disk Cleanup executed.%cRES%
call :PauseToContinue
goto :EOF

:: =====================================================================
::                       3. SYSTEM OPTIMIZATION
:: =====================================================================
:SystemOptimizeMenu
call :LogNav "System Optimization Menu"
cls & call :DrawBox "SYSTEM OPTIMIZATION" "%cCYA%" & echo.
echo  [1] Check Disk Integrity (Admin)
echo  [2] Defrag / Trim Drive (Admin)
echo  [3] Rebuild System Caches
echo  [4] Optimize Power Plan (Admin)
echo  [5] Optimize Visual Effects
echo  [6] Windows 11 Classic Context Menu (Toggle)
echo  [0] Back to Main Menu
echo.
set "opt="
set /p "opt= %cCYA%Choose option: %cRES%"
call :LogInput "System Opt Choice" "!opt!"

if "!opt!"=="" goto SystemOptimizeMenu
if "!opt!"=="1" (call :CheckAdmin && (cls & echo %cCYA%[+] Running Check Disk...%cRES% & call :RunAndLog chkdsk %OS_DRIVE% /scan & echo %cGRE%[+] Done.%cRES% & call :PauseToContinue))
if "!opt!"=="2" (call :CheckAdmin && (cls & echo %cCYA%[+] Running Defrag/Trim...%cRES% & call :RunAndLog defrag %OS_DRIVE% /O /L & echo %cGRE%[+] Done.%cRES% & call :PauseToContinue))
if "!opt!"=="3" (
    cls & echo %cCYA%[+] Rebuilding icon ^& thumbnail caches...%cRES%
    call :RunAndLog taskkill /f /im explorer.exe
    timeout /t 1 /nobreak >nul
    call :RunAndLog del /a /f /q "%localappdata%\IconCache.db"
    call :RunAndLog del /a /f /q "%localappdata%\Microsoft\Windows\Explorer\thumbcache_*.db"
    start explorer.exe
    if "!IS_ADMIN!"=="1" (sc query "WSearch" >nul 2>&1 && (call :RunAndLog net stop "WSearch" & call :RunAndLog net start "WSearch"))
    echo  %cGRE%[+] Done.%cRES% & call :PauseToContinue
)
if "!opt!"=="4" (call :CheckAdmin && call :SetPowerPlan)
if "!opt!"=="5" (call :SetVisualEffects)
if "!opt!"=="6" (call :ToggleContextMenu)
if "!opt!"=="0" goto main_menu
goto SystemOptimizeMenu

:SetPowerPlan
cls & call :DrawBox "OPTIMIZE POWER PLAN" "%cCYA%" & echo.
powercfg /list & echo -----------------------------------
echo  [1] Add Ultimate Plan   [2] Remove Plan   [3] Set Active Plan
echo  [4] Restore Default     [0] Back to Optimization Menu
echo.
set "pp=" & set /p "pp= Choose: "
if "!pp!"=="" goto SetPowerPlan
if "!pp!"=="1" (call :RunAndLog powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 & echo %cGRE%[+] Plan Added.%cRES% & call :PauseToContinue)
if "!pp!"=="2" (set "del_guid=" & set /p "del_guid= Enter GUID to remove: " & call :RunAndLog powercfg /delete !del_guid! & call :PauseToContinue)
if "!pp!"=="3" (set "set_guid=" & set /p "set_guid= Enter GUID to set: " & call :RunAndLog powercfg /s !set_guid! & call :PauseToContinue)
if "!pp!"=="4" (call :RunAndLog powercfg /restoredefaultschemes & echo %cGRE%[+] Restored.%cRES% & call :PauseToContinue)
if "!pp!"=="0" goto :EOF
goto SetPowerPlan

:SetVisualEffects
cls & call :DrawBox "VISUAL EFFECTS" "%cCYA%" & echo.
echo  [1] Best Performance  [2] Custom (Peek+Smooth Fonts)  [3] Default  [0] Back
echo.
set "ve=" & set /p "ve= Choose: "
if "!ve!"=="1" (call :RunAndLog reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 2 /f & echo %cGRE%[+] Applied.%cRES% & call :PauseToContinue)
if "!ve!"=="2" (call :RunAndLog reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 3 /f & echo %cGRE%[+] Applied.%cRES% & call :PauseToContinue)
if "!ve!"=="3" (call :RunAndLog reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFxSetting" /t REG_DWORD /d 0 /f & echo %cGRE%[+] Restored.%cRES% & call :PauseToContinue)
if "!ve!"=="0" goto :EOF
goto SetVisualEffects

:ToggleContextMenu
cls & call :DrawBox "WIN 11 CONTEXT MENU" "%cCYA%" & echo.
echo  [1] Enable Classic Menu (Win 10 Style)
echo  [2] Restore Default Menu (Win 11 Style)
echo  [0] Back
echo.
set "cm=" & set /p "cm= Choose: "
if "!cm!"=="1" (call :RunAndLog reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve & echo %cGRE%[+] Classic Menu Enabled. (Restart Explorer to see changes)%cRES% & call :PauseToContinue)
if "!cm!"=="2" (call :RunAndLog reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f & echo %cGRE%[+] Default Menu Restored.%cRES% & call :PauseToContinue)
if "!cm!"=="0" goto :EOF
goto ToggleContextMenu

:: =====================================================================
::                       4. ADVANCED TOOLS
:: =====================================================================
:AdvancedMenu
call :LogNav "Advanced Tools Menu"
cls & call :DrawBox "ADVANCED TOOLS" "%cMAG%" & echo.
echo  [1] Clear Update Cache (Admin)
echo  [2] Uninstall Office Key (Admin)
echo  [3] Remove Windows.old (Admin+Expert)
echo  [4] Manage Pagefile/Hibernation (Admin+Expert)
echo  [5] Network Reset ^& Flush DNS (Admin)
echo  [6] Create Restore Point (Admin)
echo  [0] Back to Main Menu
echo.
set "adv="
set /p "adv= %cMAG%Choose option: %cRES%"

if "!adv!"=="" goto AdvancedMenu
if "!adv!"=="1" (call :CheckAdmin && call :ClearWinUpdate)
if "!adv!"=="2" (call :CheckAdmin && call :UninstallOfficeKey)
if "!adv!"=="3" (call :CheckAdmin && if "!EXPERT_MODE!"=="1" (call :RemoveWindowsOld) else (echo %cRED%[-] Expert Mode required.%cRES% & call :PauseToContinue))
if "!adv!"=="4" (call :CheckAdmin && if "!EXPERT_MODE!"=="1" (call :PagefileMenu) else (echo %cRED%[-] Expert Mode required.%cRES% & call :PauseToContinue))
if "!adv!"=="5" (call :CheckAdmin && call :NetReset)
if "!adv!"=="6" (call :CheckAdmin && call :CreateRestorePoint)
if "!adv!"=="0" goto main_menu
goto AdvancedMenu

:ClearWinUpdate
cls & echo %cBLU%[+] Stopping services...%cRES%
call :RunAndLog sc stop wuauserv
call :RunAndLog sc stop bits
call :RunAndLog sc stop cryptsvc
if exist "%windir%\SoftwareDistribution" call :RunAndLog rd /s /q "%windir%\SoftwareDistribution"
if exist "%windir%\System32\catroot2" call :RunAndLog rd /s /q "%windir%\System32\catroot2"
echo %cBLU%[+] Restarting services...%cRES%
call :RunAndLog net start cryptsvc
call :RunAndLog net start bits
call :RunAndLog net start wuauserv
echo %cGRE%[+] Update Cache Cleared.%cRES% & call :PauseToContinue & goto :EOF

:UninstallOfficeKey
cls & if exist "C:\Program Files\Microsoft Office\Office16\ospp.vbs" (cd /d "C:\Program Files\Microsoft Office\Office16") else (if exist "C:\Program Files (x86)\Microsoft Office\Office16\ospp.vbs" (cd /d "C:\Program Files (x86)\Microsoft Office\Office16") else (echo %cRED%[-] Office 2016 ospp.vbs not found.%cRES% & call :PauseToContinue & cd /d "%~dp0" & goto :EOF))
call :RunAndLog cscript ospp.vbs /dstatus
call :PauseToContinue & cd /d "%~dp0" & goto :EOF

:RemoveWindowsOld
cls & set "WINOLD=%OS_DRIVE%\Windows.old"
if exist "%WINOLD%" (
    echo %cYEL%WARNING: Irreversible deletion of Windows.old.%cRES% 
    set "confirm=" & set /p "confirm=Type 'YES' to proceed: "
    if /i "!confirm!"=="YES" (
        call :RunAndLog takeown /F "%WINOLD%" /R /D Y
        call :RunAndLog icacls "%WINOLD%" /grant *S-1-5-32-544:F /T
        call :RunAndLog rd /s /q "%WINOLD%" & echo %cGRE%[+] Done.%cRES%
    )
) else (echo %cYEL%[-] Windows.old not found.%cRES%)
call :PauseToContinue & goto :EOF

:PagefileMenu
cls & call :DrawBox "PAGEFILE & HIBERNATION" "%cMAG%" & echo.
echo  [1] Disable Auto Pagefile  [2] Disable Hibernation  [0] Back
echo.
set "pf=" & set /p "pf=Choose: "
if "!pf!"=="1" (call :RunAndLog wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False & echo %cGRE%[+] Disabled. Reboot needed.%cRES% & call :PauseToContinue)
if "!pf!"=="2" (call :RunAndLog powercfg -h off & echo %cGRE%[+] Hibernation disabled.%cRES% & call :PauseToContinue)
if "!pf!"=="0" goto :EOF
goto PagefileMenu

:NetReset
cls & echo %cBLU%[+] Resetting Network...%cRES%
call :RunAndLog ipconfig /flushdns
call :RunAndLog netsh winsock reset
call :RunAndLog netsh int ip reset
echo %cGRE%[+] Complete. Reboot recommended.%cRES% & call :PauseToContinue & goto :EOF

:CreateRestorePoint
cls & echo %cBLU%[+] Creating Restore Point...%cRES%
call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command "Enable-ComputerRestore -Drive '%OS_DRIVE%'"
call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'ProToolkit_Backup' -RestorePointType 'MODIFY_SETTINGS'"
if %errorlevel% equ 0 (echo %cGRE%[OK] Created.%cRES%) else (echo %cRED%[ERROR] Failed.%cRES%)
call :PauseToContinue & goto :EOF

:: =====================================================================
::                       5. SYSTEM UTILITIES
:: =====================================================================
:SystemUtilities
call :LogNav "System Utilities Menu"
cls & call :DrawBox "SYSTEM UTILITIES" "%cBLU%" & echo.
echo  [1] Show Advanced System Info
echo  [2] Restart Windows Explorer (Fix UI Glitches)
echo  [3] Kill 'Not Responding' Tasks
echo  [4] Winget Power Tools (Update, Install, Fix)
echo  [0] Back to Main Menu
echo.
set "util="
set /p "util= %cBLU%Choose option: %cRES%"

if "!util!"=="" goto SystemUtilities
if "!util!"=="1" goto SysUtil1
if "!util!"=="2" goto SysUtil2
if "!util!"=="3" goto SysUtil3
if "!util!"=="4" goto WingetMenu
if "!util!"=="0" goto main_menu
goto SystemUtilities

:SysUtil1
cls & call :DrawBox "ADVANCED SYSTEM INFO" "%cBLU%" & echo.
echo  %cCYA%[+] Fetching detailed hardware information... (Please wait)%cRES%
echo.
call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$c='Cyan'; $w='White'; " ^
    "Write-Host ' [SYSTEM AND OS]' -F $c; " ^
    "$os=Get-CimInstance Win32_OperatingSystem; $cs=Get-CimInstance Win32_ComputerSystem; $bios=Get-CimInstance Win32_BIOS; " ^
    "Write-Host ('   OS Name      : '+$os.Caption) -F $w; " ^
    "Write-Host ('   OS Version   : '+$os.Version+' ('+$os.OSArchitecture+')') -F $w; " ^
    "Write-Host ('   System Name  : '+$cs.Name) -F $w; " ^
    "Write-Host ('   BIOS Version : '+$bios.Name) -F $w; Write-Host ''; " ^
    "Write-Host ' [PROCESSOR AND BOARD]' -F $c; " ^
    "$cpu=Get-CimInstance Win32_Processor; " ^
    "Write-Host ('   CPU          : '+$cpu.Name.Trim()) -F $w; " ^
    "Write-Host ('   Cores/Threads: '+$cpu.NumberOfCores+' Cores, '+$cpu.NumberOfLogicalProcessors+' Threads') -F $w; " ^
    "$mb=Get-CimInstance Win32_BaseBoard; Write-Host ('   Motherboard  : '+$mb.Manufacturer+' '+$mb.Product) -F $w; Write-Host ''; " ^
    "Write-Host ' [MEMORY AND GRAPHICS]' -F $c; " ^
    "$rT=[math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object Capacity -Sum).Sum/1GB, 2); " ^
    "$rA=[math]::Round($os.FreePhysicalMemory/1024, 2); " ^
    "Write-Host ('   RAM Total    : '+$rT+' GB') -F $w; " ^
    "Write-Host ('   RAM Available: '+$rA+' GB') -F $w; " ^
    "foreach($g in @(Get-CimInstance Win32_VideoController)){Write-Host ('   GPU          : '+$g.Caption) -F $w}; Write-Host ''; " ^
    "Write-Host ' [STORAGE]' -F $c; " ^
    "foreach($d in @(Get-CimInstance Win32_DiskDrive)){Write-Host ('   Disk         : '+$d.Model+' ('+[math]::Round($d.Size/1GB, 2)+' GB)') -F $w}"
call :PauseToContinue & goto SystemUtilities

:SysUtil2
echo. & echo %cBLU%[+] Restarting Explorer safely...%cRES%
call :RunAndLog taskkill /f /im explorer.exe
timeout /t 1 /nobreak >nul
start explorer.exe
echo %cGRE%[+] Done.%cRES% & call :PauseToContinue & goto SystemUtilities

:SysUtil3
echo. & echo %cBLU%[+] Terminating frozen applications...%cRES%
call :RunAndLog taskkill.exe /F /FI "status eq NOT RESPONDING"
echo %cGRE%[+] Done.%cRES% & call :PauseToContinue & goto SystemUtilities

:: --- WINGET POWER TOOLS ---
:WingetMenu
cls & call :DrawBox "WINGET POWER TOOLS" "%cBLU%" & echo.
echo  %cCYA%[+] Checking for available updates... (Please wait)%cRES%
echo.
winget upgrade --include-unknown
echo.
echo  -------------------------------------------------------------
echo  %cCYA%[1]%cRES% Update ALL Apps (Silent ^& Auto)
echo  %cCYA%[2]%cRES% Choose Specific Applications to Update (By ID)
echo  %cCYA%[3]%cRES% Recheck ^& Clear Output Screen
echo  %cCYA%[4]%cRES% Fix ^& Reset Winget Cache
echo  %cCYA%[5]%cRES% Install Essential Software
echo  %cCYA%[0]%cRES% Back to Utilities Menu
echo  -------------------------------------------------------------
echo.
set "w_opt="
set /p "w_opt= %cBLU%Choose option: %cRES%"

if "!w_opt!"=="" goto WingetMenu
if "!w_opt!"=="1" goto WingetUpdateAll
if "!w_opt!"=="2" goto WingetSelectUpdate
if "!w_opt!"=="3" goto WingetMenu
if "!w_opt!"=="4" goto WingetFix
if "!w_opt!"=="5" goto WingetInstall
if "!w_opt!"=="0" goto SystemUtilities
goto WingetMenu

:WingetUpdateAll
echo.
echo  %cCYA%[+] Upgrading ALL applications in background...%cRES%
call :RunAndLog winget upgrade --all --include-unknown --accept-source-agreements --accept-package-agreements --disable-interactivity
echo. & echo  %cGRE%[+] Finished updating.%cRES%
call :PauseToContinue & goto WingetMenu

:WingetSelectUpdate
echo.
echo  %cYEL%Tip: Copy or type the App ID from the list above.
echo       You can enter multiple IDs separated by space.
echo       (Example: Mozilla.Firefox Google.Chrome 7zip.7zip)%cRES%
echo.
set "spec_ids="
set /p "spec_ids= %cCYA%Enter App IDs to update: %cRES%"

if "!spec_ids!"=="" goto WingetMenu
echo.
for %%I in (!spec_ids!) do (
    echo  %cBLU%[+] Updating %%I...%cRES%
    call :RunAndLog winget upgrade --id="%%I" --exact --include-unknown --accept-source-agreements --accept-package-agreements --disable-interactivity
    echo.
)
echo  %cGRE%[+] Finished selected updates.%cRES%
call :PauseToContinue & goto WingetMenu

:WingetInstall
cls & call :DrawBox "INSTALL ESSENTIALS" "%cBLU%" & echo.
echo  %cWHI%--- Visual C++ Redistributable ---%cRES%
echo  %cYEL%[10] INSTALL ALL VCRedist (Both x86 ^& x64)%cRES%
echo  [11] VCRedist 2005   [13] VCRedist 2008   [15] VCRedist 2010
echo  [17] VCRedist 2012   [19] VCRedist 2013   [21] VCRedist 2015-2022
echo.
echo  %cWHI%--- Web Browsers ---%cRES%
echo  [31] Google Chrome   [32] Mozilla Firefox [33] Microsoft Edge
echo  [34] Brave Browser   [35] Opera           [36] Vivaldi
echo  [37] Coc Coc         [38] Opera GX        [39] Tor Browser
echo.
echo  %cWHI%--- VPN, Proxy ^& Downloaders ---%cRES%
echo  [41] Cloudflare WARP [42] ProtonVPN       [43] Windscribe
echo  [51] IDM             [52] FDM             [53] Motrix
echo.
echo  %cWHI%--- Media ^& Other Utilities ---%cRES%
echo  [61] VLC Media Player[62] K-Lite Codec    [63] Spotify
echo  -------------------------------------------------------------
echo  [0] Back to Winget Menu
echo.
set "wi_opt="
set /p "wi_opt= %cCYA%Select software (Example: 10 31 41): %cRES%"

if "!wi_opt!"=="" goto WingetInstall
if /i "!wi_opt!"=="0" goto WingetMenu

set "pkg[11]=Microsoft.VCRedist.2005.x64 Microsoft.VCRedist.2005.x86"
set "pkg[13]=Microsoft.VCRedist.2008.x64 Microsoft.VCRedist.2008.x86"
set "pkg[15]=Microsoft.VCRedist.2010.x64 Microsoft.VCRedist.2010.x86"
set "pkg[17]=Microsoft.VCRedist.2012.x64 Microsoft.VCRedist.2012.x86"
set "pkg[19]=Microsoft.VCRedist.2013.x64 Microsoft.VCRedist.2013.x86"
set "pkg[21]=Microsoft.VCRedist.2015+.x64 Microsoft.VCRedist.2015+.x86"

set "pkg[31]=Google.Chrome" & set "pkg[32]=Mozilla.Firefox" & set "pkg[33]=Microsoft.Edge" 
set "pkg[34]=Brave.Brave" & set "pkg[35]=Opera.Opera" & set "pkg[36]=VivaldiTechnologies.Vivaldi"
set "pkg[37]=CocCoc.CocCoc" & set "pkg[38]=Opera.OperaGX" & set "pkg[39]=TorProject.TorBrowser"

set "pkg[41]=Cloudflare.Warp" & set "pkg[42]=Proton.ProtonVPN" & set "pkg[43]=Windscribe.Windscribe"
set "pkg[51]=Tonec.InternetDownloadManager" & set "pkg[52]=FreeDownloadManager.FDM" 
set "pkg[53]=Motrix.Motrix"

set "pkg[61]=VideoLAN.VLC" & set "pkg[62]=CodecGuide.K-LiteCodecPack.Mega" & set "pkg[63]=Spotify.Spotify"

echo.
for %%N in (!wi_opt!) do (
    if "%%N"=="10" (
        echo  %cBLU%[+] Installing ALL Visual C++ Redistributables...%cRES%
        for %%V in (11 13 15 17 19 21) do (
            for %%P in (!pkg[%%V]!) do (
                echo  %cBLU%[+] Installing %%P...%cRES%
                call :RunAndLog winget install --id="%%P" --exact --accept-source-agreements --accept-package-agreements --disable-interactivity
            )
        )
    ) else if defined pkg[%%N] (
        for %%P in (!pkg[%%N]!) do (
            echo  %cBLU%[+] Installing %%P...%cRES%
            call :RunAndLog winget install --id="%%P" --exact --accept-source-agreements --accept-package-agreements --disable-interactivity
        )
    ) else (
        echo  %cRED%[-] Invalid option: %%N%cRES%
    )
)
echo. & echo  %cGRE%[+] Installation process complete.%cRES%
call :PauseToContinue & goto WingetInstall

:WingetFix
echo. & echo  %cCYA%[+] Updating Winget sources...%cRES%
call :RunAndLog winget source update
echo  %cCYA%[+] Resetting pins (if any)...%cRES%
call :RunAndLog winget pin reset --force
echo. & echo  %cGRE%[+] Winget cache cleared and sources updated.%cRES%
call :PauseToContinue & goto WingetMenu

:: =====================================================================
::                      6. SCREEN & POWER TOOLS
:: =====================================================================
:ScreenToolsMenu
cls & call :DrawBox "SCREEN AND POWER TOOLS" "%cYEL%" & echo.
echo  [1] Turn Off Screen Immediately
echo  [2] Create "Turn Off Screen.bat" on Desktop
echo  [0] Back to Main Menu
echo.
set "scr_choice="
set /p "scr_choice= %cYEL%Choose option: %cRES%"

if "!scr_choice!"=="" goto ScreenToolsMenu
if "!scr_choice!"=="1" goto ScrOffNow
if "!scr_choice!"=="2" goto ScrOffBat
if "!scr_choice!"=="0" goto main_menu
goto ScreenToolsMenu

:ScrOffNow
powershell -Command "(Add-Type '[DllImport(\"user32.dll\")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)"
goto ScreenToolsMenu

:ScrOffBat
for /f "delims=" %%I in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('Desktop')"') do set "real_desktop=%%I"
set "bat_path=!real_desktop!\Turn Off Screen.bat"

(
echo @echo off
echo title Turn Off Screen
echo cls ^& color 0B
echo setlocal enabledelayedexpansion
echo for /l %%%%i in (3,-1,1) do (
echo      cls ^& echo Turning off in %%%%i seconds...
echo      timeout /t 1 ^>nul
echo )
echo echo Turning off now...
echo powershell -Command "(Add-Type '[DllImport(\"user32.dll\")]public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);' -Name a -Pas)::SendMessage(-1,0x0112,0xF170,2)"
echo exit /b
) > "!bat_path!"

if exist "!bat_path!" (echo  %cGRE%[+] Created: "!bat_path!"%cRES%) else (echo  %cRED%[-] Error: Could not create file at "!bat_path!"%cRES%)
call :PauseToContinue & goto ScreenToolsMenu

:: =====================================================================
::                       7. QUICK RENAME PRO
:: =====================================================================
:QuickRename
if not defined mode1 set "mode1=File"
if not defined mode2_code set "mode2_code=1.1"
if not defined mode2_desc set "mode2_desc=Extract: K(x).re -^> x.re"
set "remove_x=" & set "rep_a=" & set "rep_b="

:QuickRenameUI
cls & call :DrawBox "QUICK RENAME PRO" "%cGRE%" & echo.
echo  %cBLU%[+] Target Type: %mode1%%cRES%
echo  %cBLU%[+] Active Mode: %mode2_code% - %mode2_desc%%cRES%
if defined remove_x echo  %cBLU%[+] Param [x]: !remove_x!%cRES%
if defined rep_a echo  %cBLU%[+] Replace: '!rep_a!' with '!rep_b!'%cRES%
echo.
echo  %cGRE%--- CONFIGURATION ---%cRES%
echo  [0] Back to Main Menu
echo  %cYEL%[1] FILE Modes:%cRES%
echo      %cCYA%[1.1] Extract Brackets   %cRES%Ex: Report(2023).txt -^> 2023.txt
echo      %cCYA%[1.2] Sequential Series  %cRES%Ex: Folder -^> Folder - 1.jpg
echo      %cCYA%[1.3] Remove Suffix (x)  %cRES%Ex: Image_copy.png -^> Image.png
echo      %cCYA%[1.4] Replace String     %cRES%Ex: A -^> B
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
if "!target_input!"=="0" goto main_menu
if "!target_input!"=="1" (set "mode1=File" & set "mode2_code=1.1" & set "mode2_desc=Extract: K(x).re -^> x.re" & goto QuickRenameUI)
if "!target_input!"=="1.1" (set "mode1=File" & set "mode2_code=1.1" & set "mode2_desc=Extract: K(x).re -^> x.re" & goto QuickRenameUI)
if "!target_input!"=="1.2" (set "mode1=File" & set "mode2_code=1.2" & set "mode2_desc=Sequential: Folder x -^> x - 1.re" & goto QuickRenameUI)
if "!target_input!"=="1.3" (set "mode1=File" & set "mode2_code=1.3" & set "mode2_desc=Remove Suffix: K[x].re -^> K.re" & set "remove_x=" & set /p "remove_x= Enter exact suffix to remove [x]: " & goto QuickRenameUI)
if "!target_input!"=="1.4" (set "mode1=File" & set "mode2_code=1.4" & set "mode2_desc=Replace String A with B" & set "rep_a=" & set /p "rep_a= String to find [A]: " & set "rep_b=" & set /p "rep_b= Replace with [B]: " & goto QuickRenameUI)
if "!target_input!"=="2" (set "mode1=Folder" & set "mode2_code=2.1" & set "mode2_desc=Extract: K(x) -^> x" & goto QuickRenameUI)
if "!target_input!"=="2.1" (set "mode1=Folder" & set "mode2_code=2.1" & set "mode2_desc=Extract: K(x) -^> x" & goto QuickRenameUI)
if "!target_input!"=="2.2" (set "mode1=Folder" & set "mode2_code=2.2" & set "mode2_desc=Remove Suffix: K[x] -^> K" & set "remove_x=" & set /p "remove_x= Enter exact suffix to remove [x]: " & goto QuickRenameUI)
if "!target_input!"=="3" goto QuickRenameUI
if "!target_input!"=="3.1" goto QuickRenameUI

if "!target_input!"=="3.2" (
    if not exist "!UNDO_LOG!" (echo  %cRED%[-] Nothing to undo.%cRES% & goto SubQuickRenameLoop)
    echo  %cBLU%[+] Undoing last rename batch...%cRES%
    call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "$log = $env:UNDO_LOG; if (Test-Path $log) { $lines = @(Get-Content $log); $idx = -1; " ^
        "for ($i = $lines.Count - 1; $i -ge 0; $i--) { if ($lines[$i] -eq '---BATCH_START---') { $idx = $i; break } }; " ^
        "if ($idx -ne -1) { $b = @(); if ($idx -lt $lines.Count - 1) { $b = @($lines[($idx + 1)..($lines.Count - 1)]) }; " ^
        "[array]::Reverse($b); foreach ($l in $b) { $p = $l -split '\|'; if ($p.Length -eq 3) { " ^
        "$fp = Join-Path $p[0] $p[1]; if (Test-Path -LiteralPath $fp) { " ^
        "try { Rename-Item -LiteralPath $fp -NewName $p[2] -Force -ErrorAction Stop; Write-Host ('  [UNDO OK] ' + $p[1] + ' -> ' + $p[2]) -ForegroundColor Yellow } " ^
        "catch { Write-Host ('  [-] UNDO FAILED: ' + $p[1]) -ForegroundColor Red } " ^
        "} } }; if ($idx -gt 0) { Set-Content -Path $log -Value $lines[0..($idx - 1)] -Force } " ^
        "else { Remove-Item $log -Force } } else { Write-Host '[-] No recent actions.' -ForegroundColor Yellow; Remove-Item $log -Force } }"
    echo  %cGRE%[+] Undo complete!%cRES%
    goto SubQuickRenameLoop
)

set "target_dir=!target_input:"=!"
if not exist "!target_dir!\" (echo  %cRED%[-] Path does not exist. Please drag a valid folder.%cRES% & goto SubQuickRenameLoop)

echo  %cBLU%[+] Processing mode %mode2_code% in: !target_dir!...%cRES%
>> "%UNDO_LOG%" echo ---BATCH_START---

if "%mode2_code%"=="1.1" call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Get-ChildItem -LiteralPath $env:target_dir -File | Where-Object { $_.BaseName -match '^.*\((.*?)\)$' } | ForEach-Object { " ^
    "  $nn = ($_.BaseName -replace '^.*\((.*?)\)$', '$1') + $_.Extension; $old = $_.Name; " ^
    "  try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; " ^
    "  Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; " ^
    "  Add-Content -Path $env:UNDO_LOG -Value ($_.DirectoryName + '|' + $nn + '|' + $old); " ^
    "  } catch { Write-Host ('  [-] SKIPPED: ' + $old) -ForegroundColor Red } }"

if "%mode2_code%"=="1.2" call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$folder = Get-Item -LiteralPath $env:target_dir; $fName = $folder.Name; " ^
    "$files = Get-ChildItem -LiteralPath $folder.FullName -File | Sort-Object @{e={[regex]::Replace($_.BaseName, '\d+', [System.Text.RegularExpressions.MatchEvaluator]{param($m) $m.Value.PadLeft(10, '0')})}}; " ^
    "$temp = @(); foreach ($f in $files) { $tmp = $f.Name + '.tmp_ren'; try { Rename-Item -LiteralPath $f.FullName -NewName $tmp -Force -ErrorAction Stop; $temp += [PSCustomObject]@{ Old = $f.Name; Tmp = $tmp; Ext = $f.Extension } } catch {} }; " ^
    "$i = 1; foreach ($t in $temp) { $nn = $fName + ' - ' + $i + $t.Ext; try { Rename-Item -LiteralPath (Join-Path $folder.FullName $t.Tmp) -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $t.Old + ' -> ' + $nn) -ForegroundColor Green; Add-Content -Path $env:UNDO_LOG -Value ($folder.FullName + '|' + $nn + '|' + $t.Old) } catch {}; $i++ }"

if "%mode2_code%"=="1.3" call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$rx = [regex]::Escape($env:remove_x); Get-ChildItem -LiteralPath $env:target_dir -File | Where-Object { $_.BaseName -match ($rx + '$') } | ForEach-Object { " ^
    "  $nn = ($_.BaseName -replace ($rx + '$'), '') + $_.Extension; $old = $_.Name; " ^
    "  try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; Add-Content -Path $env:UNDO_LOG -Value ($_.DirectoryName + '|' + $nn + '|' + $old) } catch {} }"

if "%mode2_code%"=="1.4" call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ra = [regex]::Escape($env:rep_a); $rb = $env:rep_b; Get-ChildItem -LiteralPath $env:target_dir -File | Where-Object { $_.Name -match $ra } | ForEach-Object { " ^
    "  $nn = $_.Name -replace $ra, $rb; $old = $_.Name; " ^
    "  try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; Add-Content -Path $env:UNDO_LOG -Value ($_.DirectoryName + '|' + $nn + '|' + $old) } catch {} }"

if "%mode2_code%"=="2.1" call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Get-ChildItem -LiteralPath $env:target_dir -Directory | Where-Object { $_.Name -match '^.*\((.*?)\)$' } | ForEach-Object { " ^
    "  $nn = $_.Name -replace '^.*\((.*?)\)$', '$1'; $old = $_.Name; " ^
    "  try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; Add-Content -Path $env:UNDO_LOG -Value ($_.Parent.FullName + '|' + $nn + '|' + $old) } catch {} }"

if "%mode2_code%"=="2.2" call :RunAndLog powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$rx = [regex]::Escape($env:remove_x); Get-ChildItem -LiteralPath $env:target_dir -Directory | Where-Object { $_.Name -match ($rx + '$') } | ForEach-Object { " ^
    "  $nn = $_.Name -replace ($rx + '$'), ''; $old = $_.Name; " ^
    "  try { Rename-Item -LiteralPath $_.FullName -NewName $nn -Force -ErrorAction Stop; Write-Host ('  [OK] ' + $old + ' -> ' + $nn) -ForegroundColor Green; Add-Content -Path $env:UNDO_LOG -Value ($_.Parent.FullName + '|' + $nn + '|' + $old) } catch {} }"

echo  %cGRE%[+] Done^^!%cRES%
goto SubQuickRenameLoop

:: =====================================================================
::                   8. AUTO MAINTENANCE (ADMIN)
:: =====================================================================
:AutoRun
call :CheckAdmin || goto :EOF
cls & call :DrawBox "AUTO MAINTENANCE" "%cRED%"
set "confirm=" & set /p "confirm=%cYEL%Type 'AUTO' to start: %cRES%"
if /i not "!confirm!"=="AUTO" goto :EOF
call :QuickClean & call :DeepClean & call :ClearWinUpdate
echo %cGRE%[+] FULL MAINTENANCE COMPLETE.%cRES%
set "rebootq=" & set /p "rebootq=Reboot now? (Y/N): "
if /i "!rebootq!"=="Y" shutdown /r /t 10
goto :EOF

:: =====================================================================
::                   9. TOOLKIT OPTIONS
:: =====================================================================
:Options
cls & call :DrawBox "OPTIONS & LOGS" "%cYEL%" & echo.
echo  [1] Toggle Expert Mode (Show hidden/dangerous options)
echo  [2] Export Action Report
echo  [0] Back to Main Menu
echo.
set "opt_c="
set /p "opt_c= %cYEL%Choose option: %cRES%"

if "!opt_c!"=="" goto Options
if "!opt_c!"=="1" (if "!EXPERT_MODE!"=="0" (set "EXPERT_MODE=1") else (set "EXPERT_MODE=0"))
if "!opt_c!"=="2" (
    if not exist "%TMP_LOGFILE%" (echo %cRED%[-] No actions to export.%cRES% & call :PauseToContinue & goto :EOF)
    for /f "usebackq" %%i in (`powershell -Command "Get-Date -Format 'yyyyMMddHHmm'"`) do set "NOW=%%i"
    set "EXP=%BASE_DIR%\Log_!NOW!.txt"
    copy "%TMP_LOGFILE%" "!EXP!" >nul
    echo %cGRE%[+] Exported: !EXP!%cRES% & start "" "%BASE_DIR%" & call :PauseToContinue
)
goto :EOF

:: =====================================================================
::                        HELPER FUNCTIONS
:: =====================================================================

:CheckAdmin
if "!IS_ADMIN!"=="0" (
    echo.
    echo  %cRED%[!] Nhan chuc nang nay yeu cau quyen Administrator.%cRES%
    set /p "elevate=%cYEL%Khoi chay lai cong cu bang Admin ngay lap tuc? (Y/N): %cRES%"
    if /i "!elevate!"=="Y" (
        powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
        exit
    )
    exit /b 1
)
exit /b 0

:CreateNewTempLog
>> "%TMP_LOGFILE%" echo --- Started: %date% %time% ---
goto :EOF

:LogNav
>> "%TMP_LOGFILE%" echo [%time%] [NAV] Entered: %~1
goto :EOF

:LogInput
>> "%TMP_LOGFILE%" echo [%time%] [INPUT] %~1 = %~2
goto :EOF

:LogAction
>> "%TMP_LOGFILE%" echo [%time%] [ACTION] %~1
goto :EOF

:LogError
>> "%ERROR_LOGFILE%" echo [%date% %time%] [ERROR] %~1
goto :EOF

:CleanDir
if exist "%~1" (
    echo %cBLU%[+] Cleaning %~2...%cRES%
    >> "%TMP_LOGFILE%" echo [%time%] [ACTION] Cleaning %~2
    pushd "%~1" 2>nul && (
        del /f /s /q * >nul 2>&1
        for /d %%D in (*) do rd /s /q "%%D" >nul 2>&1
        popd
        echo  %cGRE%[OK] %~2 cleaned.%cRES%
    ) || call :LogError "Failed to access %~2"
)
goto :EOF

:RunAndLog
>> "%TMP_LOGFILE%" echo [%time%] [CMD RUN] %*
%* >> "%TMP_LOGFILE%" 2>&1
set "RET=!errorlevel!"
if !RET! equ 0 (>> "%TMP_LOGFILE%" echo [%time%] [STATUS] OK) else (>> "%TMP_LOGFILE%" echo [%time%] [STATUS] ERROR CODE: !RET!)
>> "%TMP_LOGFILE%" echo ----------------------------------------
exit /b !RET!

:SummarizeLog
cls & call :DrawBox "SESSION SUMMARY" "%cMAG%"
echo.
echo  %cCYA%[+] Here is a brief summary of what happened this session:%cRES%
echo  --------------------------------------------------------------
if exist "%TMP_LOGFILE%" (findstr /C:"[NAV]" /C:"[INPUT]" /C:"ERROR CODE" "%TMP_LOGFILE%") else (echo   No actions recorded.)
echo  --------------------------------------------------------------
echo  %cGRE%Full log is available in memory until you exit.%cRES%
pause
goto :EOF

:DrawBox
setlocal
set "fullText=%~1"
set "text=!fullText!"
set "color=%~2"
set "len=0"
:len_loop
if defined text (set "text=!text:~1!" & set /a len+=1 & goto len_loop)
set "padding=" & for /l %%A in (1,1,%len%) do set "padding=!padding!="
echo.
echo  !color! +-%padding%-+!cRES!
echo  !color! ^| !fullText! ^|!cRES!
echo  !color! +-%padding%-+!cRES!
endlocal & goto :EOF

:PauseToContinue
echo. & echo  %cYEL%==========================================%cRES%
echo  %cWHI%DONE! Press any key to return...%cRES%
echo  %cYEL%==========================================%cRES% & pause >nul & goto :EOF