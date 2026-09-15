import AppKit
import Combine
import Foundation
import SwiftUI

@MainActor
final class HotkeyStore: ObservableObject {
    static let shared = HotkeyStore()

    static let bundleId = "engineer.badry.hotkeydetective"
    static let ignoreKey = "engineer.badry.hotkeydetective.hotkeys.ignoreBundleIds"

    @Published var search = ""
    @Published var systemHotkeys: [SystemHotkey] = []
    @Published var menuHotkeys: [MenuHotkey] = []
    @Published var captures: [Capture] = []
    @Published var ignoreBundleIds: [String] = []
    @Published var stolenChord: Chord?
    @Published var recording = false
    @Published var systemError: String?
    @Published var menuError: String?
    @Published var tapFailed = false
    @Published var permissionError: String?
    @Published var accessibilityTrusted = false
    @Published var loginError: String?
    @Published var exportNote: String?
    @Published var animationToken = 0

    private var scanTask: Task<Void, Never>?
    private var started = false

    private init() {
        loadIgnore()
        start()
    }

    func start() {
        guard !started else { return }
        started = true
        accessibilityTrusted = Permissions.isAccessibilityTrusted()
        reloadSystem()
        wireTap()
        EventTap.shared.start()
        scanTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.scanMenus()
                EventTap.shared.retryIfNeeded()
                try? await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }

    func refresh() {
        reloadSystem()
        Task { await scanMenus() }
        EventTap.shared.retryIfNeeded()
        accessibilityTrusted = Permissions.isAccessibilityTrusted()
    }

    func reloadSystem() {
        switch SystemHotkeys.load() {
        case .success(let items):
            systemHotkeys = items
            systemError = nil
        case .failure(let error):
            systemHotkeys = []
            systemError = error.localizedDescription
        }
        animationToken += 1
    }

    func scanMenus() async {
        accessibilityTrusted = Permissions.isAccessibilityTrusted()
        let ignore = Set(ignoreBundleIds)
        let rows = await Task.detached(priority: .utility) {
            MenuScanner.scan(ignoreBundleIds: ignore)
        }.value
        menuHotkeys = rows
        menuError = nil
        animationToken += 1
    }

    func toggleRecording() {
        recording.toggle()
        EventTap.shared.setRecording(recording)
        if recording {
            EventTap.shared.retryIfNeeded()
        }
    }

    func clearStolen() {
        stolenChord = nil
        recording = false
        EventTap.shared.setRecording(false)
    }

    func addIgnore(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let parts = trimmed.split { $0 == "," || $0 == " " || $0 == "\n" }.map(String.init)
        for part in parts where !part.isEmpty && !ignoreBundleIds.contains(part) {
            ignoreBundleIds.append(part)
        }
        persistIgnore()
        Task { await scanMenus() }
    }

    func removeIgnore(_ id: String) {
        ignoreBundleIds.removeAll { $0 == id }
        persistIgnore()
        Task { await scanMenus() }
    }

    func exportTSV() {
        var lines = ["source\tchord\tdetail"]
        for item in visibleSystem {
            lines.append("System\t\(item.chord.display)\t\(item.id)")
        }
        for item in visibleMenus {
            lines.append("Menu\t\(item.chord.display)\t\(item.appName)\t\(item.bundleId)\t\(item.menuPath)")
        }
        for item in visibleCaptures {
            lines.append("Capture\t\(item.chord.display)\t\(item.frontmostName)\t\(iso(item.time))")
        }
        NSPasteboard.general.clearContents()
        let ok = NSPasteboard.general.setString(lines.joined(separator: "\n"), forType: .string)
        exportNote = ok ? "Copied \(lines.count - 1) rows" : "Pasteboard write failed"
        animationToken += 1
    }

    func promptAccessibility() {
        permissionError = nil
        _ = Permissions.promptAccessibility()
        do {
            try Permissions.openAccessibilitySettings()
        } catch {
            permissionError = error.localizedDescription
        }
        accessibilityTrusted = Permissions.isAccessibilityTrusted()
    }

    func openInputMonitoring() {
        permissionError = nil
        do {
            try Permissions.openInputMonitoringSettings()
        } catch {
            permissionError = error.localizedDescription
        }
        EventTap.shared.retryIfNeeded()
    }

    func isConflict(_ chord: Chord, kind: ConflictKind) -> Bool {
        let menuCount = menuHotkeys.filter { $0.chord == chord }.count
        let systemHit = systemHotkeys.contains { $0.chord == chord }
        switch kind {
        case .system:
            return menuCount > 0
        case .menu:
            return menuCount > 1 || systemHit
        }
    }

    enum ConflictKind {
        case system
        case menu
    }

    var visibleSystem: [SystemHotkey] {
        systemHotkeys.filter { matches(chord: $0.chord, extra: $0.id) }
    }

    var visibleMenus: [MenuHotkey] {
        menuHotkeys.filter { matches(chord: $0.chord, extra: $0.appName, $0.bundleId, $0.menuPath) }
    }

    var visibleCaptures: [Capture] {
        captures.filter { matches(chord: $0.chord, extra: $0.frontmostName) }
    }

    private func matches(chord: Chord, extra: String...) -> Bool {
        if let stolenChord, stolenChord != chord { return false }
        let q = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return true }
        if chord.display.lowercased().contains(q) { return true }
        if extra.joined(separator: " ").lowercased().contains(q) { return true }
        return false
    }

    private func wireTap() {
        EventTap.shared.onFailure = { [weak self] in
            Task { @MainActor in
                self?.tapFailed = true
            }
        }
        EventTap.shared.onKey = { [weak self] chord, name, captureWorthy in
            Task { @MainActor in
                guard let self else { return }
                if self.recording {
                    self.stolenChord = chord
                    self.recording = false
                    EventTap.shared.setRecording(false)
                }
                if captureWorthy {
                    self.captures.insert(
                        Capture(id: UUID(), chord: chord, frontmostName: name, time: Date()),
                        at: 0
                    )
                    if self.captures.count > 200 {
                        self.captures.removeLast(self.captures.count - 200)
                    }
                }
                self.tapFailed = false
                self.animationToken += 1
            }
        }
    }

    private func loadIgnore() {
        ignoreBundleIds = UserDefaults.standard.stringArray(forKey: Self.ignoreKey) ?? []
    }

    private func persistIgnore() {
        UserDefaults.standard.set(ignoreBundleIds, forKey: Self.ignoreKey)
    }

    private func iso(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }
}
