import AppKit
import ApplicationServices

enum Permissions {
    static func isAccessibilityTrusted() -> Bool {
        AXIsProcessTrusted()
    }

    @discardableResult
    static func promptAccessibility() -> Bool {
        AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary)
    }

    static func openAccessibilitySettings() throws {
        try open(urlString: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    }

    static func openInputMonitoringSettings() throws {
        try open(urlString: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
    }

    private static func open(urlString: String) throws {
        guard let url = URL(string: urlString) else {
            throw PermissionError.invalidURL(urlString)
        }
        if !NSWorkspace.shared.open(url) {
            throw PermissionError.openFailed(urlString)
        }
    }

    enum PermissionError: LocalizedError {
        case invalidURL(String)
        case openFailed(String)

        var errorDescription: String? {
            switch self {
            case .invalidURL(let s):
                return "Invalid settings URL: \(s)"
            case .openFailed(let s):
                return "Could not open System Settings (\(s))"
            }
        }
    }
}
