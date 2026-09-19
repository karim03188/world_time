# Building the Windows Installer for World Clock

This folder has everything needed to turn the app into an installable
`Setup.exe`. After installing:

- The app is installed into a fixed folder (`Program Files\World Clock`),
  not a temporary location — this is what keeps **"Start with Windows"**
  from breaking if the app folder is later moved.
- A Start Menu shortcut is created, plus an optional desktop shortcut.
- The app is registered in Windows **"Add or Remove Programs"** and removed
  cleanly by the standard uninstaller.
- You can also enable **"Start automatically with Windows"** right from the
  installer.

## Prerequisites (one-time setup)

1. **Flutter SDK** must be installed and on PATH (the same one you're
   already using to work on this project).
2. Install **Inno Setup** (free, open source):
   - Download from `https://jrsoftware.org/isdl.php`
   - Run the installer and accept the defaults — Inno Setup 6 or 7 both
     work with the script in this folder.

## Method 1 — one command, fully automated (recommended)

From the project root (`world_time`), run in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File installer\build_installer.ps1
```

This script:

1. Runs `flutter build windows --release` (compiles the app).
2. Locates Inno Setup and compiles `installer\setup.iss`.
3. Produces the final installer at
   `installer\Output\WorldClock-Setup-1.0.0.exe`.

That single `WorldClock-Setup-1.0.0.exe` file can be handed to any Windows
PC and double-click installed — no Flutter or other tooling needed on the
target machine.

## Method 2 — manual (if you want step-by-step control)

```powershell
# 1) Build the release binary
flutter build windows --release

# 2) Compile the installer (if ISCC.exe isn't on PATH, use the full path,
#    e.g. & "C:\Program Files\Inno Setup 7\ISCC.exe" installer\setup.iss)
iscc installer\setup.iss
```

Or open `installer\setup.iss` in the **Inno Setup Compiler IDE** (installed
alongside Inno Setup) and press **Compile** (F9).

## After bumping the app version

Every time you release a new version:

1. Bump `version:` in [pubspec.yaml](../pubspec.yaml).
2. Update `#define MyAppVersion` in [installer/setup.iss](setup.iss) to
   match.
3. Re-run `build_installer.ps1`.

**Never change `AppId`** inside `setup.iss` — that fixed value is what
tells Windows a new version should upgrade the previous install in place,
rather than creating a separate side-by-side install.

## Troubleshooting

- **"flutter: command not found"**: make sure the Flutter SDK is on PATH
  (run from the same terminal where `flutter doctor` works).
- **"Could not find ISCC.exe"**: Inno Setup isn't installed, or isn't in
  its default location; use Method 2 with the full path to `ISCC.exe`.
- **Build output looks stale/empty**: delete
  `build\windows\x64\runner\Release` and re-run
  `flutter build windows --release`.
- **Antivirus or SmartScreen flags the installer**: expected — this
  installer isn't signed with a code-signing certificate. To remove this
  warning entirely, buy a code-signing certificate and enable the
  `SignTool` section in `setup.iss`. For personal/internal use, it's safe
  to click "More info → Run anyway".
