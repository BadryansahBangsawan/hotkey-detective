# Hotkey Detective

Find colliding keyboard shortcuts: system hotkeys, menu key equivalents in running apps, and chords you actually press.

Menu extra for macOS 14+. It lives in the menu bar and does not show a Dock icon.

## Features

- Record a chord, then filter the lists to that shortcut.
- System shortcuts parsed from macOS.
- Menu-bar key equivalents from running regular apps (Accessibility).
- Live capture of modifier chords (Input Monitoring).
- Export the current lists as TSV.
- Ignore apps by bundle identifier.

## Requirements

- macOS 14 Sonoma or later
- Swift 5.9 or later (Xcode or Command Line Tools)
- Accessibility to read other apps’ menus
- Input Monitoring to capture keys you press

## Install

Homebrew (macOS 14+):

```bash
brew tap BadryansahBangsawan/mac-menu-apps
brew install --cask hotkey-detective
```

Opens as a menu extra (no Dock icon). The cask is ad-hoc signed. If Gatekeeper blocks it:

```bash
xattr -cr /Applications/HotkeyDetective.app
```

Build from source:

```bash
git clone https://github.com/BadryansahBangsawan/hotkey-detective.git
cd hotkey-detective
bash package-app.sh
open dist/HotkeyDetective.app
```

Enable **Open at Login** from Settings if you want it after reboot.

## Usage

- Click the keyboard extra in the menu bar.
- **Record chord** listens for the next shortcut, then filters System / menus / captures to matches.
- **Refresh** reloads system and menu lists. **Export TSV** writes a table you can paste into a spreadsheet.
- Conflicts are marked when the same chord appears in more than one source.

## Permissions

- **Accessibility** — required to walk other apps’ menus. Without it, the menu list stays empty and the panel tells you to open Accessibility.
- **Input Monitoring** — required for the event tap. If macOS disables the tap, the panel shows **Input Monitoring denied**.

Denied permissions must not crash the app. You should see a banner and a button to open System Settings.

## Privacy

No network. Ignore lists live in UserDefaults. Nothing is uploaded.

Bundle ID: `engineer.badry.hotkeydetective`.

## Development

```bash
swift build
swift build -c release --product HotkeyDetective
```

Layout: `Sources/` (SwiftPM executable), `Info.plist`, `Assets/AppIcon.icns`, `package-app.sh`.

## License

[MIT](LICENSE)
