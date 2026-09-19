; World Clock — Inno Setup installer script
;
; Builds a single setup.exe that:
;   - installs the app into a per-user folder (no admin rights required)
;   - creates Start Menu + optional Desktop shortcuts
;   - registers a proper uninstaller in "Add or Remove Programs"
;
; Note: "Start with Windows" is handled entirely by the app itself (the
; launch_at_startup package, toggled from in-app Settings), which writes a
; single HKCU\...\Run registry entry. The installer must NOT also place a
; shortcut in the Startup folder — having both running at once launches two
; copies of the app on every boot (see the duplicate-widget bug this
; replaced).
;
; Prerequisite: run `flutter build windows --release` first so that
; ..\build\windows\x64\runner\Release exists and is up to date.
;
; Compile with Inno Setup 6 or 7 (https://jrsoftware.org/isinfo.php):
;   iscc installer\setup.iss
; or open this file in the Inno Setup Compiler IDE and press F9.

#define MyAppName "World Clock"
#define MyAppVersion "1.0.1"
#define MyAppPublisher "Karim Farhang"
#define MyAppExeName "world_time.exe"
#define MyBuildDir "..\build\windows\x64\runner\Release"

[Setup]
; Generate your own GUID once (Inno Setup menu: Tools > Generate GUID) and
; keep it fixed forever — it is how Windows recognizes upgrades vs. a
; brand-new install.
AppId={{B6C6E9B4-4B6E-4C7E-9C7D-2B7B7E7B8B9A}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
; Per-user install by default so no admin prompt (UAC) is required and the
; per-user "Run" startup registry key used by the app matches the same user.
PrivilegesRequired=lowest
OutputDir=Output
OutputBaseFilename=WorldClock-Setup-{#MyAppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[InstallDelete]
; Versions before 1.0.1 placed a shortcut in the Startup folder AND the app
; itself registers a Run key — that combination launched two copies of the
; app on every boot. Remove the old shortcut when upgrading in place so it
; doesn't linger after this fix is installed.
Type: files; Name: "{userstartup}\{#MyAppName}.lnk"

[Files]
Source: "{#MyBuildDir}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyBuildDir}\*.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#MyBuildDir}\data\*"; DestDir: "{app}\data"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName} now"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; The app writes only to shared_preferences (registry-backed) and the
; Windows "Run" startup key; both are cleaned up by the uninstaller
; automatically. No extra app-data folder to remove.
Type: filesandordirs; Name: "{app}"
; Belt-and-suspenders: removes the Startup-folder shortcut a pre-1.0.1
; install may have left behind (the duplicate-launch-on-boot bug).
Type: files; Name: "{userstartup}\{#MyAppName}.lnk"
