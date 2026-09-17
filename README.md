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

1. Download the archive:

   ⬇️ **[Download `world_time_windows_x64.zip`](/world_time_windows_x64.zip)** (or use the files inside the [`release/`](/release) folder)

2. Extract the archive.
3. Run `world_time.exe` from the extracted folder.
4. Optional: enable **Start with Windows** in Settings to launch automatically on sign-in.

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