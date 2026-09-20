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

## Troubleshooting

**Hotkeys not showing up**  
Hotkey Detective reads registrations through the Accessibility API. If the list is empty, grant Accessibility permission: **System Settings → Privacy & Security → Accessibility → toggle Hotkey Detective on**. Quit and reopen the app after granting.

**Menu bar icon missing after install**  
If the icon disappears after a reboot, the app may not be set to launch at login. Open the app once manually — it will re-add itself to the Login Items list automatically. On macOS Sequoia and later, also check **System Settings → General → Login Items & Extensions** and allow Hotkey Detective if it was removed or blocked.

**Hotkey owner shows "Unknown"**  
Some system-level shortcuts registered by macOS itself or kernel extensions are not attributed to a bundle ID. This is expected; the shortcut is still blocked at the OS level rather than by a user app.

**Quit vs hide**  
Closing the popover only dismisses the menu — the app stays in the menu bar. To fully quit, open the menu and choose **Quit Hotkey Detective** (or use Activity Monitor). Reloading Accessibility permissions also requires a full quit and reopen.

**Shortcut still stolen after identifying the owner**  
Quitting the owner app is not always enough: some apps re-register global hotkeys as soon as they relaunch or when a helper process stays running. Quit the helper from Activity Monitor (search the same bundle name), or disable the conflicting shortcut inside that app’s own settings, then reopen Hotkey Detective to confirm the binding is gone.

---

<div align="center">

Made with ♥ for developers who prefer staying in the flow.

</div>

