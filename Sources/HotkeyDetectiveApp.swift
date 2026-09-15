import SwiftUI

@main
struct HotkeyDetectiveApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Hotkey Detective", systemImage: "keyboard") {
            RootView()
                .environmentObject(HotkeyStore.shared)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(HotkeyStore.shared)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        Task { @MainActor in
            HotkeyStore.shared.start()
        }
    }
}
