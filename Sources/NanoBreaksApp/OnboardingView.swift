import AppKit
import SwiftUI
import NanoBreaksCore

@MainActor
final class OnboardingWindowController {
    private weak var model: AppModel?
    private var window: NSWindow?

    init(model: AppModel) {
        self.model = model
    }

    func show() {
        guard let model else { return }
        if window == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 520, height: 500),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.title = "Welcome to NanoBreaks"
            window.center()
            window.contentView = NSHostingView(rootView: OnboardingView(model: model))
            self.window = window
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func close() {
        window?.orderOut(nil)
    }
}

struct OnboardingView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 8) {
                Text("small breaks for the mind, body, voice, and psyche")
                    .font(.largeTitle.bold())
                Text("NanoBreaks mixes tiny eye, body, mindfulness, creative, expressive, and playful breaks into your workday.")
                    .foregroundStyle(.secondary)
            }

            Picker("Your mix", selection: Binding(
                get: { model.settings.mixPreset },
                set: { model.updatePreset($0) }
            )) {
                ForEach(MixPreset.allCases.filter { $0 != .custom }) { preset in
                    Text(preset.title).tag(preset)
                }
            }
            .pickerStyle(.segmented)

            Picker("Movement", selection: Binding(
                get: { model.settings.movementMode },
                set: { model.updateMovementMode($0) }
            )) {
                ForEach(MovementMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }

            Toggle("Show movement prompts", isOn: Binding(
                get: { model.settings.enabledCategories.contains(.movement) },
                set: { model.setCategory(.movement, enabled: $0) }
            ))

            HStack {
                Text("Reminder interval")
                Spacer()
                Picker("", selection: Binding(
                    get: { model.settings.reminderIntervalMinutes },
                    set: { model.updateInterval($0) }
                )) {
                    ForEach(stride(from: 10, through: 120, by: 5).map { $0 }, id: \.self) { minutes in
                        Text("\(minutes) min").tag(minutes)
                    }
                }
                .frame(width: 130)
            }

            Text("Choose only activities that are safe for you and your surroundings. You can swap or hide anything, with no penalty.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Button("Start NanoBreaks") { model.completeOnboarding() }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(28)
        .frame(width: 520, height: 500)
    }
}
