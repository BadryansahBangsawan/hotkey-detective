import Foundation

struct Chord: Hashable, Sendable {
    var command: Bool
    var shift: Bool
    var option: Bool
    var control: Bool
    var keyLabel: String

    var display: String {
        var s = ""
        if control { s += "⌃" }
        if option { s += "⌥" }
        if shift { s += "⇧" }
        if command { s += "⌘" }
        s += keyLabel
        return s
    }

    var hasNonShiftModifier: Bool {
        command || option || control
    }
}

enum KeyMapping {
    static func label(for keyCode: Int) -> String {
        labels[keyCode] ?? "Key \(keyCode)"
    }

    /// ANSI-US virtual key codes 0–126 (letters, digits, F1–F12, arrows, space, tab, esc, return, extras).
    static let labels: [Int: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V",
        10: "§", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T",
        18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9",
        26: "7", 27: "-", 28: "8", 29: "0", 30: "]", 31: "O", 32: "U", 33: "[",
        34: "I", 35: "P", 36: "Return", 37: "L", 38: "J", 39: "'", 40: "K", 41: ";",
        42: "\\", 43: ",", 44: "/", 45: "N", 46: "M", 47: ".", 48: "Tab", 49: "Space",
        50: "`", 51: "Delete", 52: "Enter", 53: "Esc",
        54: "⌘", 55: "⌘", 56: "Shift", 57: "Caps Lock", 58: "Option", 59: "Control",
        60: "Shift", 61: "Option", 62: "Control", 63: "Fn",
        64: "F17", 65: "Keypad .", 67: "Keypad *", 69: "Keypad +", 71: "Clear",
        72: "Volume Up", 73: "Volume Down", 74: "Mute", 75: "Keypad /", 76: "Keypad Enter",
        78: "Keypad -", 79: "F18", 80: "F19", 81: "Keypad =",
        82: "Keypad 0", 83: "Keypad 1", 84: "Keypad 2", 85: "Keypad 3", 86: "Keypad 4",
        87: "Keypad 5", 88: "Keypad 6", 89: "Keypad 7", 91: "Keypad 8", 92: "Keypad 9",
        96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8", 101: "F9", 103: "F11",
        105: "F13", 106: "F16", 107: "F14", 109: "F10", 111: "F12", 113: "F15",
        114: "Help", 115: "Home", 116: "Page Up", 117: "Forward Delete", 118: "F4",
        119: "End", 120: "F2", 121: "Page Down", 122: "F1",
        123: "←", 124: "→", 125: "↓", 126: "↑"
    ]

    /// SymbolicHotKeys / NSEvent modifier bits: 17 shift, 18 control, 19 option, 20 command.
    static func chord(keyCode: Int, carbonModifiers: Int) -> Chord {
        let m = carbonModifiers
        return Chord(
            command: m & (1 << 20) != 0 || m & (1 << 8) != 0,
            shift: m & (1 << 17) != 0 || m & (1 << 9) != 0,
            option: m & (1 << 19) != 0 || m & (1 << 11) != 0,
            control: m & (1 << 18) != 0 || m & (1 << 12) != 0,
            keyLabel: label(for: keyCode)
        )
    }

    /// AX menu item modifiers: bit0 shift, bit1 option, bit2 control, bit3 no-command. Command is implied.
    static func chord(cmdChar: String?, virtualKey: Int?, axModifiers: Int) -> Chord? {
        let noCommand = axModifiers & (1 << 3) != 0
        let command = !noCommand
        let shift = axModifiers & (1 << 0) != 0
        let option = axModifiers & (1 << 1) != 0
        let control = axModifiers & (1 << 2) != 0
        let trimmed = cmdChar?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let keyLabel: String
        if let virtualKey, trimmed.isEmpty {
            keyLabel = label(for: virtualKey)
        } else if !trimmed.isEmpty {
            keyLabel = trimmed.uppercased()
        } else if let virtualKey {
            keyLabel = label(for: virtualKey)
        } else {
            return nil
        }
        if !command && !shift && !option && !control {
            return nil
        }
        return Chord(command: command, shift: shift, option: option, control: control, keyLabel: keyLabel)
    }
}

struct SystemHotkey: Identifiable, Hashable, Sendable {
    let id: String
    let chord: Chord
}

struct MenuHotkey: Identifiable, Hashable, Sendable {
    let id: String
    let appName: String
    let bundleId: String
    let menuPath: String
    let chord: Chord

    init(appName: String, bundleId: String, menuPath: String, chord: Chord) {
        self.id = "\(bundleId)|\(menuPath)|\(chord.display)"
        self.appName = appName
        self.bundleId = bundleId
        self.menuPath = menuPath
        self.chord = chord
    }
}

struct Capture: Identifiable, Hashable, Sendable {
    let id: UUID
    let chord: Chord
    let frontmostName: String
    let time: Date
}
