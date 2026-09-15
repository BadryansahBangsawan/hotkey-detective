import Foundation

enum SystemHotkeys {
    static let unreadableMessage = "Cannot read system hotkeys"

    static func load() -> Result<[SystemHotkey], Error> {
        let domains: [CFString] = [
            "apple.symbolichotkeys" as CFString,
            "com.apple.symbolichotkeys" as CFString
        ]
        var lastRaw: CFPropertyList?
        for domain in domains {
            if let raw = CFPreferencesCopyAppValue("AppleSymbolicHotKeys" as CFString, domain) {
                lastRaw = raw
                break
            }
        }
        guard let lastRaw else {
            return .failure(HotkeyError.unreadable)
        }
        let dict: [AnyHashable: Any]
        if let typed = lastRaw as? [String: Any] {
            dict = typed
        } else if let typed = lastRaw as? [AnyHashable: Any] {
            dict = typed
        } else if let ns = lastRaw as? NSDictionary {
            var mapped: [AnyHashable: Any] = [:]
            ns.enumerateKeysAndObjects { key, value, _ in
                if let k = key as? AnyHashable {
                    mapped[k] = value
                }
            }
            dict = mapped
        } else {
            return .failure(HotkeyError.unreadable)
        }

        var result: [SystemHotkey] = []
        for (key, value) in dict {
            guard let entry = dictionary(from: value) else {
                continue
            }
            guard isEnabled(entry["enabled"]) else { continue }
            let params: [Any]
            if let valueDict = dictionary(from: entry["value"]), let p = array(from: valueDict["parameters"]) {
                params = p
            } else {
                continue
            }
            guard let parsed = parseParameters(params) else { continue }
            if parsed.keyCode == 65535 { continue }
            let chord = KeyMapping.chord(keyCode: parsed.keyCode, carbonModifiers: parsed.modifiers)
            result.append(SystemHotkey(id: String(describing: key), chord: chord))
        }
        result.sort { lhs, rhs in
            if lhs.chord.display == rhs.chord.display { return lhs.id < rhs.id }
            return lhs.chord.display < rhs.chord.display
        }
        return .success(result)
    }

    private static func isEnabled(_ value: Any?) -> Bool {
        if let i = intValue(value) { return i == 1 }
        if let b = value as? Bool { return b }
        return false
    }

    private static func parseParameters(_ params: [Any]) -> (keyCode: Int, modifiers: Int)? {
        let ints = params.compactMap(intValue)
        // Apple format: [ascii, keyCode, modifiers]
        if ints.count >= 3 {
            return (ints[1], ints[2])
        }
        // Plan format: [keyCode, modifiers, …]
        if ints.count >= 2 {
            return (ints[0], ints[1])
        }
        return nil
    }

    private static func intValue(_ any: Any?) -> Int? {
        guard let any else { return nil }
        if let i = any as? Int { return i }
        if let i = any as? Int64 { return Int(i) }
        if let i = any as? UInt64 { return Int(i) }
        if let n = any as? NSNumber { return n.intValue }
        if let d = any as? Double { return Int(d) }
        if let s = any as? String { return Int(s) }
        return nil
    }

    private static func dictionary(from any: Any?) -> [String: Any]? {
        if let d = any as? [String: Any] { return d }
        if let d = any as? NSDictionary {
            var mapped: [String: Any] = [:]
            d.enumerateKeysAndObjects { key, value, _ in
                mapped[String(describing: key)] = value
            }
            return mapped
        }
        return nil
    }

    private static func array(from any: Any?) -> [Any]? {
        if let a = any as? [Any] { return a }
        if let a = any as? NSArray { return a as? [Any] ?? a.map { $0 as Any } }
        return nil
    }

    enum HotkeyError: LocalizedError {
        case unreadable
        var errorDescription: String? { SystemHotkeys.unreadableMessage }
    }
}
