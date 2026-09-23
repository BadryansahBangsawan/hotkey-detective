<div align="center">

# Hotkey Detective

**Find colliding keyboard shortcuts: system hotkeys, menu key equivalents, and chords you press.**

Menu extra for macOS 14+. Lives on the **right** of the menu bar. No Dock icon.

<br/>

[![Build](https://github.com/BadryansahBangsawan/hotkey-detective/actions/workflows/ci.yml/badge.svg)](https://github.com/BadryansahBangsawan/hotkey-detective/actions/workflows/ci.yml)
[![Latest Release](https://img.shields.io/github/v/release/BadryansahBangsawan/hotkey-detective?style=flat-square)](https://github.com/BadryansahBangsawan/hotkey-detective/releases/latest)
[![macOS](https://img.shields.io/badge/macOS-14%2B-black?style=flat-square&logo=apple)](https://github.com/BadryansahBangsawan/hotkey-detective/releases/latest)

<br/>

| | |
|---|---|
| Product | `HotkeyDetective` |
| Bundle ID | `engineer.badry.hotkeydetective` |
| Cask | `hotkey-detective` |
| Status item | SF Symbol `keyboard` |
| Panel | opaque ~360×420 pt |

</div>

---

## What you get

| Piece | Behavior |
|---|---|
| **Record** | **Record chord** listens for the next shortcut, then filters System / menus / captures. **Clear filter** drops it. |
| **System** | Enabled system hotkeys. Same chord in more than one source is marked **Conflict**. |
| **Menus** | Key equivalents from running regular apps (Accessibility). |
| **Captures** | Chords you pressed (Input Monitoring event tap). |
| **Export** | **Export TSV** copies the current lists. Ignore bundle IDs in Settings. |
| **Login** | Open at Login from Settings (`SMAppService`). |

---

## Download

| File | Use |
|---|---|
| **`HotkeyDetective.app.zip`** | Homebrew cask / unzip, drag **HotkeyDetective** onto **Applications** |

**[Releases](https://github.com/BadryansahBangsawan/hotkey-detective/releases/latest)**

---

## Install

### Homebrew

```bash
brew tap BadryansahBangsawan/mac-menu-apps
brew trust BadryansahBangsawan/mac-menu-apps
brew install --cask hotkey-detective
```

`brew trust` is required on Homebrew 6 or `brew install --cask` refuses the tap.

First open (ad-hoc signed):

```bash
xattr -cr /Applications/HotkeyDetective.app
open /Applications/HotkeyDetective.app
```

Still blocked: System Settings → Privacy & Security → Open Anyway.

Do not run `dist/HotkeyDetective.app` while `/Applications/HotkeyDetective.app` is running (same bundle ID).

---

## How to open

This is an `LSUIElement` extra. Proof it is running is the **keyboard** status item on the **right** of the menu bar, not a window from Finder or Launchpad.

1. Click that extra. The panel is opaque ~360×420 pt, not a 10px strip.
2. If the bar is full, look behind the Control Center overflow chevron **«**.
3. Double-clicking in Finder/Launchpad only changes the left-side app name. That is expected. There is no Dock icon.

---

## Usage

1. **Search** filters by shortcut or app name.
2. **Record chord** listens for the next shortcut, then filters the lists. **Clear filter** when a stolen chord is shown.
3. **Refresh** reloads system and menu lists. **Export TSV** copies a table.
4. Ignore bundle IDs in Settings so those apps are skipped when scanning menus.
5. **Settings** at the bottom: Open at Login, ignore list, Quit.

---

## Permissions

**Accessibility** — walk other apps’ menus. Without it, the menu list stays empty.

**Input Monitoring** — event tap (`CGPreflightListenEventAccess`). If macOS disables the tap, the panel shows **Input Monitoring denied**.

Denied permissions must not crash the extra. You get a red label and buttons to open System Settings.

Ad-hoc `codesign -s -` binds TCC to a **cdhash**. Every rebuild is a new identity. System Settings can still show the **old** row as enabled.

1. System Settings → Privacy & Security → Accessibility (and Input Monitoring).
2. Turn the switch **off**, then **on** for Hotkey Detective (remove duplicate rows if you see two).
3. Click **Relaunch**. macOS does not grant these rights to a process that is already running.

---

## Data

| What | Where |
|---|---|
| Ignore bundle IDs | UserDefaults `engineer.badry.hotkeydetective.hotkeys.ignoreBundleIds` |
| Open at Login | `SMAppService.mainApp` (Settings toggle) |

Nothing under Application Support.

---

## Privacy

No network. Ignore lists live in UserDefaults. Menu titles and key events stay on this Mac.

---

## Uninstall

```bash
brew uninstall --cask hotkey-detective
```

Or delete `/Applications/HotkeyDetective.app`.

This does not delete UserDefaults or TCC entries. Remove the extra from Accessibility / Input Monitoring in System Settings if it remains.

Turn off **Hotkey Detective** in System Settings → General → Login Items if it remains.

---

## Troubleshooting

| What you see | What to do |
|---|---|
| Finder “opens” nothing / no Dock icon | Click the **keyboard** extra on the right of the menu bar. |
| Extra missing | Overflow **«**, or `pgrep -x HotkeyDetective` then `open /Applications/HotkeyDetective.app`. |
| “Damaged” / cannot verify | `xattr -cr /Applications/HotkeyDetective.app`. `spctl --assess` is `rejected` even when it runs. |
| `brew install --cask` refuses the tap | `brew trust BadryansahBangsawan/mac-menu-apps` |
| Accessibility already checked, extra still nags | Toggle off/on, then **Relaunch** (cdhash). |
| **Input Monitoring denied** | Same: toggle off/on, **Relaunch**. |
| **Conflict** | Same chord in more than one source. Intended. Closing the panel does not Quit — use **Quit**. |
| Extra gone after reboot | Open the app once. Sequoia+: System Settings → General → Login Items & Extensions. |
| ~10px empty strip under the bar | Reinstall from this repo. |

---

## Build from source

```bash
git clone https://github.com/BadryansahBangsawan/hotkey-detective.git
cd hotkey-detective
swift build -c release --product HotkeyDetective
bash package-app.sh
open dist/HotkeyDetective.app
```

Tag `v*` runs CI: `HotkeyDetective.app.zip`. Never commit `dist/`.

Layout: `Sources/` (SwiftPM executable), `Info.plist`, `Assets/AppIcon.icns`, `package-app.sh`. `FunTheme.swift` is copied verbatim (no shared package).

---

## FAQ

**Why is there no Dock icon?**  
It is a menu extra. Click the keyboard item on the **right** of the menu bar.

**Why is Accessibility already on, but menus are empty?**  
Ad-hoc signing binds TCC to a **cdhash**. Toggle **off then on**, then **Relaunch**.

**Where is the ignore list?**  
UserDefaults `engineer.badry.hotkeydetective.hotkeys.ignoreBundleIds`.

**How do I stop it opening at login?**  
Settings in the panel, or System Settings → General → Login Items → **Hotkey Detective**.

---

<div align="center">

[MIT](LICENSE)

</div>
