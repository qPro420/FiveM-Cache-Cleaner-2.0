# FiveM Cache Cleaner

A Windows utility for clearing FiveM's local data and running the original PC optimization steps, with shortcuts to built-in Windows gaming and storage settings.

## Use

1. Run `FiveM-Cache-Cleaner.bat`.
2. Choose **Full cleanup and PC optimization** for the full cleanup. Close FiveM and GTA V first.
3. Choose **Optimize a running FiveM session** while FiveM is open to set its process priority.

The full cleanup asks for confirmation, checks that FiveM/GTA V are closed, then removes these folders when present:

- `%LocalAppData%\FiveM\FiveM.app\data\cache`
- `%LocalAppData%\FiveM\FiveM.app\data\game-storage`
- `%LocalAppData%\FiveM\FiveM.app\data\nui-storage`
- `%LocalAppData%\FiveM\FiveM.app\data\server-cache`
- `%LocalAppData%\FiveM\FiveM.app\data\server-cache-priv`
- `%LocalAppData%\FiveM\FiveM.app\logs`
- `%LocalAppData%\FiveM\FiveM.app\crashes`

It also clears the contents of the current user's `%TEMP%` folder, after verifying the Temp path is inside the user profile. Temp files locked or protected by Windows may remain. Full cleanup activates the Windows High Performance power plan and force-closes GTA V Launcher, AnyDesk, Cortana, and TeamViewer processes when running. Since FiveM must be closed for cleanup, it cannot change FiveM's priority in that mode.

The running-session option applies the power plan, force-closes those same processes, and sets running FiveM processes to High priority without clearing files. FiveM process matching includes versioned names such as `FiveM_b3258_GTAProcess.exe`.

FiveM may need to redownload or rebuild local data. Logs and crash reports will no longer be available for troubleshooting. Force-closing AnyDesk or TeamViewer can disconnect remote sessions. High Performance may increase power use and heat, and High process priority does not guarantee better FPS or latency. Review or change the power plan in Windows after use if desired.

The tool does not delete data belonging to other applications outside the user Temp folder or open external websites. Its other menu options open Windows Game Mode, Graphics, and Storage settings.

## Notes

- The cleaner expects the standard FiveM install location under `%LocalAppData%\FiveM`.
- Windows PowerShell is used to check and set FiveM process priority.
- The full cleanup runs only while FiveM/GTA V are closed. Use the running-session option for priority changes during gameplay.

## Original project

This project was originally created by qPro. See [LICENSE](LICENSE) for license terms.
