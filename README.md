<div align="center">

# Hotkey Detective

**Find which app is stealing your keyboard shortcuts.**  
macOS menu extra — lives in the menu bar, no Dock icon.

<br/>

[![Latest Release](https://img.shields.io/github/v/release/BadryansahBangsawan/hotkey-detective?style=flat-square&color=76B900&label=latest)](https://github.com/BadryansahBangsawan/hotkey-detective/releases/latest)
[![macOS](https://img.shields.io/badge/macOS-14%2B-black?style=flat-square&logo=apple)](https://github.com/BadryansahBangsawan/hotkey-detective/releases/latest)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org)

<br/>

</div>

---

## Download

| Platform | File |
|---|---|
| **macOS** (Apple Silicon & Intel, macOS 14+) | `HotkeyDetective-*-macos.zip` |

[Go to Releases](https://github.com/BadryansahBangsawan/hotkey-detective/releases/latest)

---

## Installation

### Homebrew (recommended)

```bash
brew tap BadryansahBangsawan/mac-menu-apps
brew install --cask hotkey-detective
```

A **Hotkey Detective** icon appears in the menu bar. If Gatekeeper blocks it on first launch:

```bash
xattr -cr /Applications/HotkeyDetective.app && open /Applications/HotkeyDetective.app
```

Or: right-click the app, Open, then Open again. Still blocked? **System Settings → Privacy & Security → Open Anyway**.

### GitHub Releases

1. Download `HotkeyDetective-*-macos.zip` from [Releases](https://github.com/BadryansahBangsawan/hotkey-detective/releases/latest)
2. Unzip and drag **HotkeyDetective** into Applications
3. On first launch, run the xattr command above if Gatekeeper blocks it

### Build from source

```bash
git clone https://github.com/BadryansahBangsawan/hotkey-detective.git
cd hotkey-detective
bash package-app.sh
open dist/HotkeyDetective.app
```

Requires Xcode Command Line Tools and Swift 5.9+.

---

## Notes

– Lists all registered global hotkeys system-wide.
– Shows which app owns each shortcut.
– Requires Accessibility permission to inspect hotkey registrations.
– No Dock icon; lives entirely in the menu bar.

---

<div align="center">

Made with ♥ for developers who prefer staying in the flow.

</div>

