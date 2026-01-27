import Foundation
import Cocoa
import Combine

class ModifierKeyMonitor: ObservableObject {
    static let shared = ModifierKeyMonitor()

    // Callback closures
    var onFnKeyDown: (() -> Void)?
    var onFnKeyUp: (() -> Void)?

    private var isFnPressed = false
    private var eventMonitor: Any?
    private var localEventMonitor: Any?

    @Published var isEnabled = false {
        didSet {
            if isEnabled {
                startMonitoring()
            } else {
                stopMonitoring()
            }
        }
    }

    private init() {}

    func startMonitoring() {
        stopMonitoring() // Ensure we don't double monitor

        // Monitor global events (when app is in background)
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
        }

        // Monitor local events (when app is active)
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handleFlagsChanged(event)
            return event
        }

        print("Fn key monitoring started")
    }

    func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }

        if let localMonitor = localEventMonitor {
            NSEvent.removeMonitor(localMonitor)
            localEventMonitor = nil
        }

        isFnPressed = false
    }

    private func handleFlagsChanged(_ event: NSEvent) {
        // Check specifically for Right Command key (KeyCode 54)
        // Left Command is 55. We only want to trigger on the right one to avoid conflicts with common shortcuts.
        guard event.keyCode == 54 else { return }

        // Check if the command key is part of the flags
        // When checking specifically for a key code in flagsChanged,
        // if the flag is present, it's a key down. If absent, it's a key up.
        let newIsPressed = event.modifierFlags.contains(.command)

        // Only trigger actions on state change
        if newIsPressed != isFnPressed {
            isFnPressed = newIsPressed

            DispatchQueue.main.async {
                if self.isFnPressed {
                    // Right Command Key Down
                    print("Right Command key pressed")
                    self.onFnKeyDown?()
                } else {
                    // Right Command Key Up
                    print("Right Command key released")
                    self.onFnKeyUp?()
                }
            }
        }
    }
}
