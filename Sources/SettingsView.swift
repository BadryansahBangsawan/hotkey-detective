import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: HotkeyStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var loginOn = SMAppService.mainApp.status == .enabled
    @State private var loginStatus: String?
    @State private var newIgnore = ""

    var body: some View {
        Form {
            Section("General") {
                Toggle("Open at Login", isOn: loginBinding)
                if let loginStatus {
                    Text(loginStatus)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                Button(store.recording ? "Listening…" : "Record chord") {
                    store.toggleRecording()
                }
                if let stolen = store.stolenChord {
                    HStack {
                        Text("Filter: \(stolen.display)")
                        Button("Clear") { store.clearStolen() }
                    }
                }
            }

            Section("Ignore bundle IDs") {
                HStack {
                    TextField("com.example.app", text: $newIgnore)
                        .onSubmit(addIgnore)
                    Button("Add", action: addIgnore)
                }
                if store.ignoreBundleIds.isEmpty {
                    Text("No ignored apps. Menu scan includes every regular app.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(store.ignoreBundleIds, id: \.self) { bid in
                        HStack {
                            Text(bid)
                                .font(.system(.body, design: .monospaced))
                            Spacer()
                            Button {
                                store.removeIgnore(bid)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }

            Section("Permissions") {
                Button("Open Accessibility") { store.promptAccessibility() }
                Button("Open Input Monitoring") { store.openInputMonitoring() }
                if let err = store.permissionError {
                    Label(err, systemImage: "exclamationmark.octagon.fill")
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button("Quit") {
                    NSApp.terminate(nil)
                }
            }
        }
        .frame(width: FunTheme.panelWidth)
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.ignoreBundleIds)
        .animation(reduceMotion ? nil : FunTheme.spring, value: store.recording)
    }

    private var loginBinding: Binding<Bool> {
        Binding(
            get: { loginOn },
            set: { enabled in
                do {
                    if enabled {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                    loginStatus = nil
                } catch {
                    loginStatus = error.localizedDescription
                }
                loginOn = SMAppService.mainApp.status == .enabled
            }
        )
    }

    private func addIgnore() {
        store.addIgnore(newIgnore)
        newIgnore = ""
    }
}
