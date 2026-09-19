# 🌍 World Clock — Desktop Widget for Windows

A small, transparent, modern desktop widget for Windows that shows live time for cities around the world — all at once. No internet required, no account, no backend. Download, run, done.

![World Clock](/clock_widget.png)

---

## ✨ Features

- ⏰ Live clock, updates every second
- 🌐 180+ cities worldwide, powered by the standard IANA Time Zone database
- ➕ Add / remove / reorder cities
- 🎯 Reference city (Compare With) — shows the time difference of every city against it (default: Kabul)
- 💎 100% transparent background (no card) — clean look right on the desktop
- 📐 Three sizes: Small / Medium / Large, plus free resize by dragging the edges
- 📌 "Always on Desktop" mode — stays behind every window, never gets in the way
- 🏠 Auto-start with Windows (toggle in Settings)
- 💾 Saves all settings, window position and size between runs
- 🚫 No internet, no backend, no ads, no account

---

## 📥 Download & Install

**Requirements:** Windows 10 or 11 (64-bit)

⬇️ **[Download WorldClock-Setup-1.0.0.exe](installer/Output/WorldClock-Setup-1.0.0.exe)**

This installer puts the app in a fixed folder, adds a Start Menu entry, and
registers a proper uninstaller in "Add or Remove Programs" — which is what
keeps **Start with Windows** reliable across reboots (a portable exe moved
around later would break that setting).

1. Run `WorldClock-Setup-1.0.0.exe`.
2. Optionally check **Start World Clock automatically when Windows starts**
   during install (or enable it later from in-app Settings).
3. Done — the app launches, and Windows will remember it after every
   restart.

Want to build the installer yourself from source instead? See
[`installer/README.md`](installer/README.md) (one PowerShell command).

> 💡 The widget does not appear in the taskbar — this is intentional; it behaves as a desktop widget.

---

## 🚀 Getting Started

- **Settings** ⚙ — click the gear icon inside the widget.
- **Add City** — search and add any city.
- **Compare With** — pick the reference city; all other cities show their time difference relative to it.
- **Size** — choose a preset size, or drag the window edges to resize freely.
- **Always on Desktop** — keeps the widget behind all other windows.
- **Start with Windows** — launches automatically at sign-in.

---

## 🛠 Build from Source

Prerequisites: [Flutter SDK](https://docs.flutter.dev/get-started/install/windows) + Visual Studio 2019/2022 (with the C++ workload)

```bash
flutter pub get
flutter build windows --release
```

The output is placed at:

```
build\windows\x64\runner\Release\
```

---

## 📝 Notes

- The app works fully **offline**; time is computed from the IANA database and settings are stored locally.
- DST (daylight saving time) changes are applied automatically.
- City flags are not displayed in the widget — Windows does not render flag emoji properly.

---

Made with ❤️ — Flutter