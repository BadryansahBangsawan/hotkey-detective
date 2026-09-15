import AppKit
import CoreGraphics

final class EventTap: @unchecked Sendable {
    static let shared = EventTap()

    var onKey: ((Chord, String, Bool) -> Void)?
    var onFailure: (() -> Void)?

    private let stateLock = NSLock()
    private var recordingFlag = false
    private var port: CFMachPort?
    private var source: CFRunLoopSource?

    var isRunning: Bool { port != nil }

    func setRecording(_ value: Bool) {
        stateLock.lock()
        recordingFlag = value
        stateLock.unlock()
    }

    private func currentlyRecording() -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        return recordingFlag
    }

    func start() {
        if port != nil { return }
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: eventTapCallback,
            userInfo: nil
        ) else {
            DispatchQueue.main.async { self.onFailure?() }
            return
        }
        port = tap
        guard let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0) else {
            CFMachPortInvalidate(tap)
            port = nil
            DispatchQueue.main.async { self.onFailure?() }
            return
        }
        source = src
        CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    func retryIfNeeded() {
        if port == nil {
            start()
        } else if let port, !CGEvent.tapIsEnabled(tap: port) {
            CGEvent.tapEnable(tap: port, enable: true)
        }
    }

    fileprivate func handle(type: CGEventType, event: CGEvent) {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let port {
                CGEvent.tapEnable(tap: port, enable: true)
            } else {
                DispatchQueue.main.async { self.onFailure?() }
            }
            return
        }
        guard type == .keyDown else { return }
        let flags = event.flags
        let command = flags.contains(.maskCommand)
        let shift = flags.contains(.maskShift)
        let option = flags.contains(.maskAlternate)
        let control = flags.contains(.maskControl)
        let recording = currentlyRecording()
        if !recording, !command, !option, !control {
            return
        }
        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        let chord = Chord(
            command: command,
            shift: shift,
            option: option,
            control: control,
            keyLabel: KeyMapping.label(for: keyCode)
        )
        let name = NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown"
        let captureWorthy = command || option || control
        DispatchQueue.main.async {
            self.onKey?(chord, name, captureWorthy)
        }
    }
}

private func eventTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    EventTap.shared.handle(type: type, event: event)
    return Unmanaged.passUnretained(event)
}
