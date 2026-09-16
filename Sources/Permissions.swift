import AppKit
import ApplicationServices
import CoreGraphics

enum Permissions {
    static func isAccessibilityTrusted() -> Bool {
        AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): false] as CFDictionary
        )
    }

    static func isListenEventTrusted() -> Bool {
        CGPreflightListenEventAccess()
    }


    static func openAccessibilitySettings() throws {
        try open(urlString: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    }

    static func openInputMonitoringSettings() throws {
        try open(urlString: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
    }

    static func relaunch() {
        let path = Bundle.main.bundlePath
        let escaped = "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/bin/zsh")
        proc.arguments = ["-c", "sleep 0.4; /usr/bin/open \(escaped)"]
        try? proc.run()
        NSApp.terminate(nil)
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
