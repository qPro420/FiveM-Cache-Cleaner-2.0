@echo off
setlocal EnableExtensions DisableDelayedExpansion
title FiveM Cache Cleaner Tool - GTADEV
color 0E

set "FIVEM_APP=%LocalAppData%\FiveM\FiveM.app"
set "FIVEM_DATA=%FIVEM_APP%\data"
set "OPTIMIZE_FAILED=0"

:MENU
cls
call :Banner
echo.
echo  [1] Full cleanup and PC optimization
echo  [2] Optimize a running FiveM session
echo  [3] Open Game Mode settings
echo  [4] Open Graphics settings
echo  [5] Open Windows Storage settings
echo  [Q] Quit
echo.
choice /c 12345Q /n /m "Choose an option: "
if errorlevel 6 goto END
if errorlevel 5 goto STORAGE_SETTINGS
if errorlevel 4 goto GRAPHICS_SETTINGS
if errorlevel 3 goto GAMEMODE_SETTINGS
if errorlevel 2 goto LIVE_OPTIMIZE
if errorlevel 1 goto FULL_CLEANUP

:FULL_CLEANUP
cls
call :Banner
echo.
echo  Full cleanup and PC optimization
echo  =================================
echo.
if not exist "%FIVEM_APP%\" (
    echo FiveM installation folder was not found:
    echo "%FIVEM_APP%"
    echo.
    pause
    goto MENU
)

powershell -NoProfile -Command "if (Get-Process -Name 'FiveM*','GTA5' -ErrorAction SilentlyContinue) { exit 1 } else { exit 0 }"
set "PROCESS_CHECK=%ERRORLEVEL%"
if "%PROCESS_CHECK%"=="1" (
    echo FiveM or GTA V appears to be running. Close it before full cleanup.
    echo Use option 2 to apply gaming optimizations while FiveM is running.
    echo No files were deleted.
    echo.
    pause
    goto MENU
)
if not "%PROCESS_CHECK%"=="0" (
    echo Could not check whether FiveM or GTA V is running.
    echo Windows PowerShell may be unavailable. Nothing was deleted.
    echo.
    pause
    goto MENU
)

echo This confirmed action will:
echo  - Delete FiveM cache, game-storage, NUI storage, logs, and crash reports.
echo  - Delete all contents in your user Temp folder.
echo  - Switch to the Windows High Performance power plan.
echo  - Force-close GTA V Launcher, AnyDesk, Cortana, and TeamViewer processes.
echo  - Skip FiveM priority changes because the game must be closed for cleanup.
echo.
echo FiveM will need to rebuild or download local data. Temp files in use may remain.
echo High Performance can increase power use and heat. Review the power plan after play.
echo To set FiveM to High priority, run option 2 while the game is open.
echo.
choice /c YN /n /m "Run full cleanup and optimization? [Y/N] "
if errorlevel 2 goto MENU

set "OPTIMIZE_FAILED=0"
call :ClearFolder "%FIVEM_DATA%\cache"
call :ClearFolder "%FIVEM_DATA%\game-storage"
call :ClearFolder "%FIVEM_DATA%\nui-storage"
call :ClearFolder "%FIVEM_DATA%\server-cache"
call :ClearFolder "%FIVEM_DATA%\server-cache-priv"
call :ClearFolder "%FIVEM_APP%\logs"
call :ClearFolder "%FIVEM_APP%\crashes"
call :ClearTemp
call :OptimizePc
goto REPORT

:LIVE_OPTIMIZE
cls
call :Banner
echo.
echo  Optimize a running FiveM session
echo  ================================
echo.
powershell -NoProfile -Command "if (Get-Process -Name 'FiveM*' -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }"
set "PROCESS_CHECK=%ERRORLEVEL%"
if "%PROCESS_CHECK%"=="1" (
    echo No FiveM process was found. Start FiveM, then choose this option.
    echo.
    pause
    goto MENU
)
if not "%PROCESS_CHECK%"=="0" (
    echo Could not check FiveM processes. Windows PowerShell may be unavailable.
    echo No optimization was applied.
    echo.
    pause
    goto MENU
)
echo This will set the running FiveM process to High priority, switch to
echo High Performance power mode, and force-close GTA V Launcher, AnyDesk,
echo Cortana, and TeamViewer processes.
echo It does not clear FiveM or Windows files.
echo.
choice /c YN /n /m "Apply these optimizations? [Y/N] "
if errorlevel 2 goto MENU
set "OPTIMIZE_FAILED=0"
call :OptimizePc
goto REPORT

:OptimizePc
echo.
echo  Applying legacy PC optimizations...
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
if errorlevel 1 (
    echo Could not activate the High Performance power plan.
    set "OPTIMIZE_FAILED=1"
) else (
    echo Activated the High Performance power plan.
)

call :StopProcess "GTAVLauncher.exe"
call :StopProcess "AnyDesk.exe"
call :StopProcess "Cortana.exe"
call :StopProcess "TeamViewer.exe"
call :StopProcess "TeamViewer_Service.exe"

powershell -NoProfile -Command "$ps=Get-Process -Name 'FiveM*' -ErrorAction SilentlyContinue; if (!$ps) { Write-Output 'No FiveM process is running; priority was not changed.'; exit 0 }; $failed=$false; foreach($p in $ps) { try { $p.PriorityClass='High'; Write-Output ('Set High priority: '+$p.ProcessName) } catch { Write-Output ('Could not change priority for '+$p.ProcessName+': '+$_.Exception.Message); $failed=$true } }; if($failed) { exit 1 }"
if errorlevel 1 set "OPTIMIZE_FAILED=1"
exit /b 0

:StopProcess
tasklist /FI "IMAGENAME eq %~1" /NH | find /I "%~1" >nul
if errorlevel 1 (
    echo Not running: %~1
    exit /b 0
)
taskkill /f /im "%~1" >nul 2>&1
if errorlevel 1 (
    echo Could not stop: %~1
    set "OPTIMIZE_FAILED=1"
) else (
    echo Stopped: %~1
)
exit /b 0

:ClearFolder
if not exist "%~1\" (
    echo Not found, skipping: "%~1"
    exit /b 0
)
rmdir /s /q "%~1"
if exist "%~1\" (
    echo Could not remove: "%~1"
    set "OPTIMIZE_FAILED=1"
) else (
    echo Removed: "%~1"
)
exit /b 0

:ClearTemp
if not defined TEMP (
    echo TEMP is not defined. Windows Temp cleanup skipped.
    set "OPTIMIZE_FAILED=1"
    exit /b 0
)
if not exist "%TEMP%\" (
    echo Temp folder was not found. Windows Temp cleanup skipped.
    exit /b 0
)
powershell -NoProfile -Command "$temp=[IO.Path]::GetFullPath($env:TEMP).TrimEnd('\'); $user=[IO.Path]::GetFullPath($env:USERPROFILE).TrimEnd('\'); if($temp.StartsWith($user+'\',[StringComparison]::OrdinalIgnoreCase)) { exit 0 } else { exit 1 }"
if errorlevel 1 (
    echo Temp cleanup skipped: the Temp path could not be verified as inside your user profile.
    set "OPTIMIZE_FAILED=1"
    exit /b 0
)
echo.
echo  Clearing contents of "%TEMP%"...
for /d %%D in ("%TEMP%\*") do if exist "%%~fD\" (
    rmdir /s /q "%%~fD" 2>nul
    if exist "%%~fD\" (
        echo Could not remove Temp folder: "%%~fD"
        set "OPTIMIZE_FAILED=1"
    )
)
del /f /q /a "%TEMP%\*" 2>nul
if exist "%TEMP%\*" (
    echo Some Temp items could not be removed because they are in use or protected.
    set "OPTIMIZE_FAILED=1"
) else (
    echo User Temp cleanup finished.
)
exit /b 0

:REPORT
echo.
if "%OPTIMIZE_FAILED%"=="1" (
    echo Finished with one or more warnings. Review the messages above.
) else (
    echo All requested actions finished.
)
echo.
pause
goto MENU

:GAMEMODE_SETTINGS
start "" "ms-settings:gaming-gamemode"
goto MENU

:GRAPHICS_SETTINGS
start "" "ms-settings:display-advancedgraphics"
goto MENU

:STORAGE_SETTINGS
start "" "ms-settings:storagesense"
goto MENU

:Banner
echo       ______           __         ________
echo      / ____/___ ______/ /_  ___  / ____/ /__  ____ _____  ___  _____
echo     / /   / __ `/ ___/ __ \/ _ \/ /   / / _ \/ __ `/ __ \/ _ \/ ___/
echo    / /___/ /_/ / /__/ / / /  __/ /___/ /  __/ /_/ / / / /  __/ /
echo    \____/\__,_/\___/_/ /_/\___/\____/_/\___/\__,_/_/ /_/\___/_/
echo                FiveM Cache Cleaner / discord.gg/GTADEV
exit /b 0

:END
endlocal
exit /b 0
