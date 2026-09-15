import AppKit
import ApplicationServices

enum MenuScanner {
    static func scan(ignoreBundleIds: Set<String>) -> [MenuHotkey] {
        guard Permissions.isAccessibilityTrusted() else { return [] }
        var results: [MenuHotkey] = []
        let apps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
        for app in apps {
            let bid = app.bundleIdentifier ?? ""
            if !bid.isEmpty, ignoreBundleIds.contains(bid) { continue }
            let name = app.localizedName ?? bid
            let axApp = AXUIElementCreateApplication(app.processIdentifier)
            var menuBarRef: AnyObject?
            let err = AXUIElementCopyAttributeValue(axApp, kAXMenuBarAttribute as CFString, &menuBarRef)
            guard err == .success, let menuBarRef, let menuBar = asElement(menuBarRef) else { continue }
            walk(menuBar, path: [], appName: name, bundleId: bid, depth: 0, into: &results)
            if results.count > 4000 { break }
        }
        return results
    }

    private static func walk(
        _ element: AXUIElement,
        path: [String],
        appName: String,
        bundleId: String,
        depth: Int,
        into results: inout [MenuHotkey]
    ) {
        if depth > 8 || results.count > 4000 { return }
        guard let children = copy(element, kAXChildrenAttribute as String) as? [AXUIElement] else { return }
        for child in children {
            let title = (copy(child, kAXTitleAttribute as String) as? String) ?? ""
            if path.isEmpty {
                if title.isEmpty || title == "Apple" || title == "" { continue }
            }
            var nextPath = path
            if !title.isEmpty, title != "-" {
                nextPath = path + [title]
                if let chord = chord(from: child) {
                    results.append(
                        MenuHotkey(
                            appName: appName,
                            bundleId: bundleId,
                            menuPath: nextPath.joined(separator: " › "),
                            chord: chord
                        )
                    )
                }
            }
            walk(child, path: nextPath, appName: appName, bundleId: bundleId, depth: depth + 1, into: &results)
        }
    }

    private static func chord(from element: AXUIElement) -> Chord? {
        let char = copy(element, kAXMenuItemCmdCharAttribute as String) as? String
        let mods = intValue(copy(element, kAXMenuItemCmdModifiersAttribute as String)) ?? 0
        let vk = intValue(copy(element, kAXMenuItemCmdVirtualKeyAttribute as String))
        let hasChar = !(char?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        if !hasChar, vk == nil { return nil }
        return KeyMapping.chord(cmdChar: char, virtualKey: vk, axModifiers: mods)
    }

    private static func copy(_ element: AXUIElement, _ attribute: String) -> AnyObject? {
        var value: AnyObject?
        let err = AXUIElementCopyAttributeValue(element, attribute as CFString, &value)
        guard err == .success else { return nil }
        return value
    }

    private static func asElement(_ value: AnyObject) -> AXUIElement? {
        let ref = value as CFTypeRef
        guard CFGetTypeID(ref) == AXUIElementGetTypeID() else { return nil }
        return unsafeBitCast(ref, to: AXUIElement.self)
    }

    private static func intValue(_ any: AnyObject?) -> Int? {
        if let n = any as? NSNumber { return n.intValue }
        if let i = any as? Int { return i }
        return nil
    }
}
