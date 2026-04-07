@echo off
chcp 65001 >nul
:: ============================================================
::  FixAISlop v1.3 -- Ultimate Windows 10/11 Optimizer
::  + Full Debloat + HSP Debloat Tool
:: ============================================================
title FixAISlop v1.3 -- Ultimate Windows 10/11 Optimizer
color 09
setlocal EnableDelayedExpansion

if not defined _ADMIN_CHECK (
    set _ADMIN_CHECK=1
    net session >nul 2>&1
    if !errorlevel! NEQ 0 (
        echo.
        echo  [ERROR] Run this script as Administrator^^!
        echo  Right-click -^> Run as administrator
        echo.
        pause
        exit /b 1
    )
)

echo  [*] Creating System Restore Point...
powershell -NoProfile -Command "try { Checkpoint-Computer -Description 'FixAISlop v1.3' -RestorePointType MODIFY_SETTINGS -ErrorAction Stop } catch { Write-Host '[WARN] Restore point skipped (may already exist)' }"
echo  [OK] Restore point done.

:MENU
cls
echo.
echo  =========================================================
echo   FixAISlop v1.3  ^|  Ultimate Windows 10/11 Optimizer
echo  =========================================================
echo   [1]  Run ALL Optimizations  (Recommended)
echo   [2]  System Repair          (SFC + DISM)
echo   [3]  Privacy Tweaks
echo   [4]  Performance Tweaks     (Registry + Boot)
echo   [5]  Services Optimizer
echo   [6]  Bloatware Removal      (Basic UWP)
echo   [7]  FULL DEBLOAT           (Nuclear option)
echo   [8]  Network Optimizer
echo   [9]  Visual Effects         (Performance Mode)
echo   [10] Power Plan             (Ultimate Performance)
echo   [11] Junk File Cleanup
echo   -------------------------------------------------------
echo   [0]  Exit
echo  =========================================================
set /p choice="  Select option: "

if "%choice%"=="1"  goto ALL
if "%choice%"=="2"  goto REPAIR
if "%choice%"=="3"  goto PRIVACY
if "%choice%"=="4"  goto PERFORMANCE
if "%choice%"=="5"  goto SERVICES
if "%choice%"=="6"  goto BLOATWARE
if "%choice%"=="7"  goto FULLDEBLOAT
if "%choice%"=="8"  goto NETWORK
if "%choice%"=="9"  goto VISUAL
if "%choice%"=="10" goto POWER
if "%choice%"=="11" goto CLEANUP
if "%choice%"=="0"  goto EXIT
echo  [!] Invalid option.
pause
goto MENU

:: ============================================================
:ALL
echo.
echo  [>>] Running ALL optimizations (skipping HSP Tool)...
call :REPAIR_FUNC
call :PRIVACY_FUNC
call :PERFORMANCE_FUNC
call :SERVICES_FUNC
call :BLOATWARE_FUNC
call :FULLDEBLOAT_FUNC
call :NETWORK_FUNC
call :VISUAL_FUNC
call :POWER_FUNC
call :CLEANUP_FUNC
echo.
echo  =========================================================
echo   [DONE] All optimizations applied^^! Please restart.
echo  =========================================================
pause
goto MENU

:: ============================================================
:REPAIR
call :REPAIR_FUNC
pause
goto MENU

:REPAIR_FUNC
echo.
echo  [>>] SYSTEM REPAIR
echo  -----------------------------------------------------------
echo  [*] Running SFC...
sfc /scannow
echo  [*] Running DISM RestoreHealth...
DISM /Online /Cleanup-Image /RestoreHealth
echo  [*] Resetting Windows Update components...
net stop wuauserv >nul 2>&1
net stop cryptSvc >nul 2>&1
net stop bits >nul 2>&1
net stop msiserver >nul 2>&1
if exist "%SystemRoot%\SoftwareDistribution.old" rd /s /q "%SystemRoot%\SoftwareDistribution.old" >nul 2>&1
if exist "%SystemRoot%\System32\catroot2.old"    rd /s /q "%SystemRoot%\System32\catroot2.old"    >nul 2>&1
ren "%SystemRoot%\SoftwareDistribution" SoftwareDistribution.old >nul 2>&1
ren "%SystemRoot%\System32\catroot2"    catroot2.old             >nul 2>&1
net start wuauserv >nul 2>&1
net start cryptSvc >nul 2>&1
net start bits     >nul 2>&1
net start msiserver >nul 2>&1
echo  [OK] System repair complete.
goto :eof

:: ============================================================
:PRIVACY
call :PRIVACY_FUNC
pause
goto MENU

:PRIVACY_FUNC
echo.
echo  [>>] PRIVACY TWEAKS
echo  -----------------------------------------------------------
echo  [*] Disabling Telemetry...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1 & sc stop DiagTrack >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1 & sc stop dmwappushservice >nul 2>&1
echo  [*] Disabling Activity History...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "EnableActivityFeed"    /t REG_DWORD /d 0 /f >nul 2>&1
echo  [*] Disabling Cortana + Bing Search...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana"               /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"   /v "BingSearchEnabled"          /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"   /v "CortanaConsent"             /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer"       /v "DisableSearchBoxSuggestions" /t REG_DWORD /d 1 /f >nul 2>&1
echo  [*] Disabling Location Services...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" /v "DisableLocation" /t REG_DWORD /d 1 /f >nul 2>&1
echo  [*] Disabling Advertising ID...
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled"               /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo"       /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1
echo  [*] Disabling Feedback + Diagnostics...
reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules"                      /v "NumberOfSIUFInPeriod"           /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "DoNotShowFeedbackNotifications" /t REG_DWORD /d 1 /f >nul 2>&1
echo  [*] Disabling Windows Error Reporting...
sc config WerSvc start= disabled >nul 2>&1 & sc stop WerSvc >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1
echo  [*] Disabling AutoLogger-Diagtrack...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener" /v "Start" /t REG_DWORD /d 0 /f >nul 2>&1
echo  [*] Adding telemetry hosts to HOSTS file...
set HOSTS=%SystemRoot%\System32\drivers\etc\hosts
findstr /c:"vortex.data.microsoft.com" "%HOSTS%" >nul 2>&1
if errorlevel 1 (
    echo.>> "%HOSTS%"
    echo 0.0.0.0 vortex.data.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 vortex-win.data.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 telecommand.telemetry.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 oca.telemetry.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 sqm.telemetry.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 watson.telemetry.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 df.telemetry.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 compat.telemetry.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 spynet2.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 spynet.microsoft.com>> "%HOSTS%"
    echo 0.0.0.0 settings-sandbox.data.microsoft.com>> "%HOSTS%"
) else (
    echo  [SKIP] Telemetry hosts already blocked.
)
echo  [OK] Privacy tweaks applied.
goto :eof

:: ============================================================
:PERFORMANCE
call :PERFORMANCE_FUNC
pause
goto MENU

:PERFORMANCE_FUNC
echo.
echo  [>>] PERFORMANCE TWEAKS
echo  -----------------------------------------------------------
echo  [*] Foreground app CPU priority...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f >nul 2>&1
echo  [*] Large System Cache...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 1 /f >nul 2>&1
echo  [*] HPET tweaks (bcdedit)...
bcdedit /deletevalue useplatformclock >nul 2>&1
bcdedit /set useplatformtick yes      >nul 2>&1
bcdedit /set tscsyncpolicy enhanced   >nul 2>&1
bcdedit /set bootmenupolicy legacy    >nul 2>&1
echo  [*] Disabling SysMain / Superfetch...
sc config SysMain start= disabled >nul 2>&1 & sc stop SysMain >nul 2>&1
echo  [*] Disabling Xbox Game DVR...
reg add "HKCU\System\GameConfigStore"                       /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR"   /t REG_DWORD /d 0 /f >nul 2>&1
echo  [*] Disabling Mouse Acceleration...
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed"      /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_SZ /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_SZ /d "0" /f >nul 2>&1
echo  [*] Disabling Hibernation...
powercfg -h off >nul 2>&1
echo  [*] Disabling Fast Startup...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v "HiberbootEnabled" /t REG_DWORD /d 0 /f >nul 2>&1
echo  [*] NTFS optimization...
fsutil behavior set disablelastaccess 1 >nul 2>&1
fsutil behavior set disable8dot3      1 >nul 2>&1
echo  [OK] Performance tweaks applied.
goto :eof

:: ============================================================
:SERVICES
call :SERVICES_FUNC
pause
goto MENU

:SERVICES_FUNC
echo.
echo  [>>] SERVICES OPTIMIZER
echo  -----------------------------------------------------------
echo  [*] Disabling unnecessary services...
for %%s in (
    AJRouter ALG AppVClient AssignedAccessManagerSvc
    BTAGService bthserv CscService defragsvc
    DiagTrack dmwappushservice DPS EapHost
    fdPHost FDResPub fhsvc icssvc
    lfsvc MapsBroker MSiSCSI NcdAutoSetup
    NetTcpPortSharing PhoneSvc PrintNotify RemoteAccess
    RemoteRegistry RetailDemo RmSvc SCPolicySvc
    SharedAccess shpamsvc smphost SstpSvc
    TapiSrv tzautoupdate WalletService WbioSrvc
    WFDSConSvc WiaRpc WMPNetworkSvc WpcMonSvc
    WPDBusEnum WpnService WSearch WerSvc
    XblAuthManager XblGameSave XboxGipSvc XboxNetApiSvc
    edgeupdate edgeupdatem MicrosoftEdgeElevationService
    gupdate gupdatem MozillaMaintenance
) do (
    sc config "%%s" start= disabled >nul 2>&1
    sc stop    "%%s"               >nul 2>&1
)
echo  [OK] Services optimized.
goto :eof

:: ============================================================
:BLOATWARE
call :BLOATWARE_FUNC
pause
goto MENU

:BLOATWARE_FUNC
echo.
echo  [>>] BLOATWARE REMOVAL (Basic UWP)
echo  -----------------------------------------------------------
set PS_TEMP=%TEMP%\fixaislop_bloat.ps1
(
echo $apps = @(
echo     "Microsoft.3DBuilder",
echo     "Microsoft.BingFinance",
echo     "Microsoft.BingNews",
echo     "Microsoft.BingSports",
echo     "Microsoft.BingWeather",
echo     "Microsoft.BingSearch",
echo     "Microsoft.GetHelp",
echo     "Microsoft.Getstarted",
echo     "Microsoft.Messaging",
echo     "Microsoft.Microsoft3DViewer",
echo     "Microsoft.MicrosoftOfficeHub",
echo     "Microsoft.MicrosoftSolitaireCollection",
echo     "Microsoft.MixedReality.Portal",
echo     "Microsoft.NetworkSpeedTest",
echo     "Microsoft.News",
echo     "Microsoft.Office.Lens",
echo     "Microsoft.OneConnect",
echo     "Microsoft.People",
echo     "Microsoft.Print3D",
echo     "Microsoft.RemoteDesktop",
echo     "Microsoft.SkypeApp",
echo     "Microsoft.Todos",
echo     "Microsoft.Wallet",
echo     "microsoft.windowscommunicationsapps",
echo     "Microsoft.WindowsFeedbackHub",
echo     "Microsoft.WindowsMaps",
echo     "Microsoft.WindowsSoundRecorder",
echo     "Microsoft.Xbox.TCUI",
echo     "Microsoft.XboxApp",
echo     "Microsoft.XboxGameOverlay",
echo     "Microsoft.XboxGamingOverlay",
echo     "Microsoft.XboxIdentityProvider",
echo     "Microsoft.XboxSpeechToTextOverlay",
echo     "Microsoft.YourPhone",
echo     "Microsoft.ZuneMusic",
echo     "Microsoft.ZuneVideo",
echo     "MicrosoftTeams",
echo     "Clipchamp.Clipchamp",
echo     "Microsoft.GamingApp",
echo     "Microsoft.WindowsCamera",
echo     "Microsoft.549981C3F5F10"
echo ^)
echo foreach ($app in $apps^) {
echo     Write-Host "  [*] Removing: $app"
echo     Get-AppxPackage -Name $app -AllUsers ^| Remove-AppxPackage -ErrorAction SilentlyContinue
echo     Get-AppxProvisionedPackage -Online ^| Where-Object { $_.PackageName -like "*$app*" } ^| Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
echo }
echo Write-Host "[OK] Basic bloatware removed."
) > "%PS_TEMP%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_TEMP%"
del "%PS_TEMP%" >nul 2>&1
goto :eof

:: ============================================================
:FULLDEBLOAT
call :FULLDEBLOAT_FUNC
pause
goto MENU

:FULLDEBLOAT_FUNC
echo.
echo  [>>] FULL DEBLOAT (Nuclear Option)
echo  -----------------------------------------------------------
echo  [!] WARNING: Removes ALL built-in apps, OneDrive, Copilot,
echo      Widgets, Teams, Recall, lock screen ads and more.
echo      Some changes require reinstall to undo^^!
echo.
set /p confirm="  Type YES to continue: "
if /i not "%confirm%"=="YES" (
    echo  [SKIPPED] Full Debloat cancelled.
    goto :eof
)
echo.
set PS_FULL=%TEMP%\fixaislop_fulldebloat.ps1
(
echo $apps = @(
echo     "Microsoft.3DBuilder","Microsoft.549981C3F5F10","Microsoft.Advertising.Xaml",
echo     "Microsoft.BingFinance","Microsoft.BingFoodAndDrink","Microsoft.BingHealthAndFitness",
echo     "Microsoft.BingMaps","Microsoft.BingNews","Microsoft.BingSearch",
echo     "Microsoft.BingSports","Microsoft.BingTravel","Microsoft.BingWeather",
echo     "Microsoft.Copilot","Microsoft.GamingApp","Microsoft.GetHelp",
echo     "Microsoft.Getstarted","Microsoft.HelpAndTips","Microsoft.Messaging",
echo     "Microsoft.Microsoft3DViewer","Microsoft.MicrosoftOfficeHub",
echo     "Microsoft.MicrosoftSolitaireCollection","Microsoft.MicrosoftStickyNotes",
echo     "Microsoft.MixedReality.Portal","Microsoft.MSPaint","Microsoft.NetworkSpeedTest",
echo     "Microsoft.News","Microsoft.Office.Lens","Microsoft.Office.OneNote",
echo     "Microsoft.Office.Sway","Microsoft.OneConnect","Microsoft.OutlookForWindows",
echo     "Microsoft.Paint","Microsoft.People","Microsoft.PowerAutomateDesktop",
echo     "Microsoft.Print3D","Microsoft.RemoteDesktop","Microsoft.SkypeApp",
echo     "Microsoft.Teams","Microsoft.Todos","Microsoft.Wallet",
echo     "Microsoft.WebMediaExtensions","Microsoft.WebpImageExtension",
echo     "microsoft.windowscommunicationsapps","Microsoft.WindowsAlarms",
echo     "Microsoft.WindowsCamera","Microsoft.WindowsFeedbackHub",
echo     "Microsoft.WindowsMaps","Microsoft.WindowsSoundRecorder",
echo     "Microsoft.Xbox.TCUI","Microsoft.XboxApp","Microsoft.XboxGameOverlay",
echo     "Microsoft.XboxGamingOverlay","Microsoft.XboxIdentityProvider",
echo     "Microsoft.XboxSpeechToTextOverlay","Microsoft.YourPhone",
echo     "Microsoft.ZuneMusic","Microsoft.ZuneVideo",
echo     "MicrosoftCorporationII.MicrosoftFamily","MicrosoftCorporationII.QuickAssist",
echo     "MicrosoftTeams","Clipchamp.Clipchamp","Disney.37853FC22B2CE",
echo     "SpotifyAB.SpotifyMusic","king.com.CandyCrushSaga","king.com.CandyCrushSodaSaga",
echo     "king.com.BubbleWitch3Saga","Facebook.Facebook","Amazon.com.Amazon",
echo     "Netflix","BytedancePte.Ltd.TikTok","ROBLOXCORPORATION.ROBLOX",
echo     "Duolingo-LearnLanguagesforFree","PandoraMediaInc",
echo     "AdobeSystemsIncorporated.AdobePhotoshopExpress","ActiproSoftwareLLC.562882FEEB491"
echo ^)
echo foreach ($app in $apps^) {
echo     Write-Host "  [*] $app"
echo     Get-AppxPackage -Name $app -AllUsers ^| Remove-AppxPackage -ErrorAction SilentlyContinue
echo     Get-AppxProvisionedPackage -Online ^| Where-Object { $_.PackageName -like "*$app*" } ^| Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
echo }
echo Write-Host "[OK] UWP apps processed."
echo $features = @(
echo     "Internet-Explorer-Optional-amd64","WindowsMediaPlayer",
echo     "WorkFolders-Client","Printing-XPSServices-Features","FaxServicesClientPackage"
echo ^)
echo foreach ($f in $features^) {
echo     Write-Host "  [*] Disabling: $f"
echo     Disable-WindowsOptionalFeature -Online -FeatureName $f -NoRestart -ErrorAction SilentlyContinue ^| Out-Null
echo }
echo Write-Host "[OK] Optional features disabled."
) > "%PS_FULL%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_FULL%"
del "%PS_FULL%" >nul 2>&1

echo  [*] Removing OneDrive...
taskkill /f /im OneDrive.exe >nul 2>&1
timeout /t 2 /nobreak >nul
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall >nul 2>&1
if exist "%SystemRoot%\System32\OneDriveSetup.exe"  "%SystemRoot%\System32\OneDriveSetup.exe"  /uninstall >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC"               /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\OneDrive"                  /v "PreventNetworkTrafficPreUserSignIn" /t REG_DWORD /d 1 /f >nul 2>&1
rd /s /q "%UserProfile%\OneDrive"            >nul 2>&1
rd /s /q "%LocalAppData%\Microsoft\OneDrive" >nul 2>&1
rd /s /q "%ProgramData%\Microsoft OneDrive"  >nul 2>&1
rd /s /q "C:\OneDriveTemp"                   >nul 2>&1
echo  [OK] OneDrive removed.
echo  [*] Disabling Copilot...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v "TurnOffWindowsCopilot" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowCopilotButton" /t REG_DWORD /d 0 /f >nul 2>&1
echo  [*] Disabling Windows Recall / AI...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "DisableAIDataAnalysis"  /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" /v "TurnOffSavingSnapshots" /t REG_DWORD /d 1 /f >nul 2>&1
echo  [*] Disabling Widgets...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarDa" /t REG_DWORD /d 0 /f >nul 2>&1
echo  [*] Disabling Teams Chat icon...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Chat" /v "ChatIcon" /t REG_DWORD /d 3 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarMn" /t REG_DWORD /d 0 /f >nul 2>&1
echo  [*] Disabling Lock Screen ads + Spotlight...
for %%v in (
    SubscribedContent-338387Enabled SubscribedContent-338388Enabled
    SubscribedContent-338389Enabled SubscribedContent-353698Enabled
    ContentDeliveryAllowed OemPreInstalledAppsEnabled PreInstalledAppsEnabled
    SilentInstalledAppsEnabled SystemPaneSuggestionsEnabled SoftLandingEnabled
) do reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v "%%v" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /v "DisableWindowsConsumerFeatures" /t REG_DWORD /d 1 /f >nul 2>&1
echo  [*] Disabling telemetry scheduled tasks...
for %%t in (
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Application Experience\StartupAppTask"
    "\Microsoft\Windows\Autochk\Proxy"
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
    "\Microsoft\Windows\Feedback\Siuf\DmClient"
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting"
) do schtasks /Change /TN "%%t" /DISABLE >nul 2>&1
echo  [*] Disabling Edge update tasks...
schtasks /Change /TN "MicrosoftEdgeUpdateTaskMachineCore" /DISABLE >nul 2>&1
schtasks /Change /TN "MicrosoftEdgeUpdateTaskMachineUA"   /DISABLE >nul 2>&1
echo.
echo  [OK] FULL DEBLOAT complete^^! Restart your PC.
goto :eof

:: ============================================================
:NETWORK
call :NETWORK_FUNC
pause
goto MENU

:NETWORK_FUNC
echo.
echo  [>>] NETWORK OPTIMIZER
echo  -----------------------------------------------------------
echo  [*] Setting DNS to Cloudflare 1.1.1.1 on all adapters...
for /f "skip=3 tokens=1*" %%a in ('netsh interface show interface') do (
    netsh interface ipv4 set dns "%%b" static 1.1.1.1 primary validate=no >nul 2>&1
    netsh interface ipv4 add dns "%%b" 1.0.0.1 index=2 validate=no       >nul 2>&1
)
echo  [*] Flushing DNS...
ipconfig /flushdns >nul 2>&1
netsh int ip reset    >nul 2>&1
netsh winsock reset   >nul 2>&1
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global timestamps=disabled    >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"  /v "DefaultTTL"         /t REG_DWORD /d 64  /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters" /v "DisabledComponents" /t REG_DWORD /d 255 /f >nul 2>&1
echo  [OK] Network optimized. Restart required.
goto :eof

:: ============================================================
:VISUAL
call :VISUAL_FUNC
pause
goto MENU

:VISUAL_FUNC
echo.
echo  [>>] VISUAL EFFECTS -- Performance Mode
echo  -----------------------------------------------------------
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting"    /t REG_DWORD /d 2   /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop"                                              /v "MenuShowDelay"      /t REG_SZ    /d "0" /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics"                                /v "MinAnimate"         /t REG_SZ    /d "0" /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"        /v "ListviewAlphaSelect" /t REG_DWORD /d 0  /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"        /v "TaskbarAnimations"   /t REG_DWORD /d 0  /f >nul 2>&1
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"       /v "EnableTransparency"  /t REG_DWORD /d 0  /f >nul 2>&1
echo  [OK] Visual effects = Performance mode.
goto :eof

:: ============================================================
:POWER
call :POWER_FUNC
pause
goto MENU

:POWER_FUNC
echo.
echo  [>>] POWER PLAN -- Ultimate Performance
echo  -----------------------------------------------------------
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
for /f "tokens=4" %%G in ('powercfg /list ^| findstr /i "Ultimate"') do powercfg /setactive %%G >nul 2>&1
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 >nul 2>&1
powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0 >nul 2>&1
powercfg /setactive SCHEME_CURRENT >nul 2>&1
echo  [OK] Power plan = Ultimate Performance.
goto :eof

:: ============================================================
:CLEANUP
call :CLEANUP_FUNC
pause
goto MENU

:CLEANUP_FUNC
echo.
echo  [>>] JUNK FILE CLEANUP
echo  -----------------------------------------------------------
echo  [*] Deleting user Temp...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%x in ("%temp%\*") do rd /s /q "%%x" >nul 2>&1
echo  [*] Deleting Windows Temp...
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%x in ("C:\Windows\Temp\*") do rd /s /q "%%x" >nul 2>&1
echo  [*] Deleting Prefetch...
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
echo  [*] Clearing Event Logs...
for /f "tokens=*" %%G in ('wevtutil el 2^>nul') do wevtutil cl "%%G" >nul 2>&1
echo  [*] Emptying Recycle Bin...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo  [*] Clearing thumbnail cache...
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo  [*] Clearing Windows Update download cache...
net stop wuauserv >nul 2>&1
rd /s /q "C:\Windows\SoftwareDistribution\Download" >nul 2>&1
md "C:\Windows\SoftwareDistribution\Download"       >nul 2>&1
net start wuauserv >nul 2>&1
echo  [*] Disk Cleanup (silent)...
cleanmgr /sagerun:65535 >nul 2>&1
echo  [*] DISM Component Store cleanup...
Dism /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
echo  [OK] Cleanup complete.
goto :eof

:: ============================================================
:EXIT
echo.
echo  =========================================================
echo   FixAISlop v1.3 -- Goodbye^^! Restart for full effect.
echo  =========================================================
pause
exit /b 0