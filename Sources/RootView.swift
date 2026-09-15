import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: HotkeyStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                TextField("Search", text: $store.search)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button(store.recording ? "Listening…" : "Record chord") {
                        store.toggleRecording()
                    }
                    .disabled(store.tapFailed && !store.recording)
                    if store.stolenChord != nil {
                        Button("Clear filter") { store.clearStolen() }
                    }
                }
                HStack {
                    Button("Refresh") { store.refresh() }
                    Button("Export TSV") { store.exportTSV() }
                }

                if let stolen = store.stolenChord {
                    Text("Showing chord \(stolen.display)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let note = store.exportNote {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let err = store.permissionError {
                    Label(err, systemImage: "exclamationmark.octagon.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                if !store.accessibilityTrusted {
                    permissionRow(
                        title: "Accessibility needed to read app menus",
                        button: "Open Accessibility",
                        action: store.promptAccessibility
                    )
                }
                if store.tapFailed {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Input Monitoring denied", systemImage: "exclamationmark.octagon.fill")
                            .foregroundStyle(.red)
                        Button("Open Input Monitoring") { store.openInputMonitoring() }
                    }
                }

                systemSection
                menusSection
                capturesSection
            }
            .funPanel()
        }
        .background(.regularMaterial)
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.animationToken)
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.search)
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.recording)
    }

    private var systemSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("System")
                .font(.headline)
            if let err = store.systemError {
                Label(err, systemImage: "exclamationmark.octagon.fill")
                    .foregroundStyle(.red)
            } else if store.visibleSystem.isEmpty {
                emptyState(
                    "No enabled system hotkeys.",
                    actionTitle: "Refresh",
                    action: store.reloadSystem
                )
            } else {
                ForEach(store.visibleSystem) { item in
                    hotkeyRow(chord: item.chord, detail: "id \(item.id)", conflict: store.isConflict(item.chord, kind: .system))
                }
            }
        }
    }

    private var menusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Running app menus")
                .font(.headline)
            if let err = store.menuError {
                Label(err, systemImage: "exclamationmark.octagon.fill")
                    .foregroundStyle(.red)
            } else if !store.accessibilityTrusted {
                emptyState(
                    "Grant Accessibility to read app menus.",
                    actionTitle: "Open Accessibility",
                    action: store.promptAccessibility
                )
            } else if store.visibleMenus.isEmpty {
                emptyState(
                    "No menu shortcuts in running apps.",
                    actionTitle: "Refresh",
                    action: { store.refresh() }
                )
            } else {
                ForEach(store.visibleMenus) { item in
                    hotkeyRow(
                        chord: item.chord,
                        detail: "\(item.appName) — \(item.menuPath)",
                        conflict: store.isConflict(item.chord, kind: .menu)
                    )
                }
            }
        }
    }

    private var capturesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Captured events")
                .font(.headline)
            if store.tapFailed {
                emptyState(
                    "No captured shortcuts yet.",
                    actionTitle: "Open Input Monitoring",
                    action: store.openInputMonitoring
                )
            } else if store.visibleCaptures.isEmpty {
                emptyState(
                    "No captured shortcuts yet.",
                    actionTitle: "Record chord",
                    action: store.toggleRecording
                )
            } else {
                ForEach(store.visibleCaptures) { item in
                    hotkeyRow(
                        chord: item.chord,
                        detail: "\(item.frontmostName) · \(item.time.formatted(date: .omitted, time: .standard))",
                        conflict: false
                    )
                }
            }
        }
    }

    private func hotkeyRow(chord: Chord, detail: String, conflict: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(chord.display)
                .font(.system(.body, design: .monospaced))
                .frame(minWidth: 72, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                if conflict {
                    Label("Conflict", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func emptyState(_ sentence: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(sentence)
                .foregroundStyle(.secondary)
            Button(actionTitle, action: action)
        }
    }

    private func permissionRow(title: String, button: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button(button, action: action)
        }
    }
}
