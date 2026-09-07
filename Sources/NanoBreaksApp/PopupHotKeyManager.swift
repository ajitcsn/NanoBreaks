import Carbon.HIToolbox

enum PopupHotKey: UInt32 {
    case swap = 1
    case eyes = 2
    case next = 3
    case complete = 4
}

private let popupHotKeySignature: OSType = 0x32304D4E // "20MN"

private let popupHotKeyHandler: EventHandlerUPP = { _, event, userData in
    guard let event, let userData else { return OSStatus(eventNotHandledErr) }
    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )
    guard status == noErr, hotKeyID.signature == popupHotKeySignature else { return OSStatus(eventNotHandledErr) }

    let manager = Unmanaged<PopupHotKeyManager>.fromOpaque(userData).takeUnretainedValue()
    MainActor.assumeIsolated {
        manager.handle(id: hotKeyID.id)
    }
    return noErr
}

@MainActor
final class PopupHotKeyManager {
    private var eventHandler: EventHandlerRef?
    private var hotKeyRefs: [EventHotKeyRef] = []
    private let action: (PopupHotKey) -> Void

    init(action: @escaping (PopupHotKey) -> Void) {
        self.action = action
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            popupHotKeyHandler,
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }

    func activate() {
        deactivate()
        register(.swap, keyCode: UInt32(kVK_ANSI_S))
        register(.eyes, keyCode: UInt32(kVK_ANSI_E))
        register(.next, keyCode: UInt32(kVK_ANSI_N))
    }

    func activateCompletion() {
        deactivate()
        register(.complete, keyCode: UInt32(kVK_ANSI_D))
    }

    func deactivate() {
        hotKeyRefs.forEach { UnregisterEventHotKey($0) }
        hotKeyRefs.removeAll()
    }

    func handle(id: UInt32) {
        guard let hotKey = PopupHotKey(rawValue: id) else { return }
        action(hotKey)
    }

    private func register(_ hotKey: PopupHotKey, keyCode: UInt32) {
        var ref: EventHotKeyRef?
        let identifier = EventHotKeyID(signature: popupHotKeySignature, id: hotKey.rawValue)
        let status = RegisterEventHotKey(
            keyCode,
            UInt32(controlKey),
            identifier,
            GetApplicationEventTarget(),
            0,
            &ref
        )
        if status == noErr, let ref { hotKeyRefs.append(ref) }
    }
}
