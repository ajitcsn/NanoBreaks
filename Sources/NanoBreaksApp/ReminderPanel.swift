import AppKit
import SwiftUI
import NanoBreaksCore

private final class FocusablePanel: NSPanel {
    override var canBecomeKey: Bool { true }

    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        guard let screen = screen ?? self.screen ?? NSScreen.main else { return frameRect }
        return frameRect.constrained(to: screen.visibleFrame.insetBy(dx: 12, dy: 12))
    }
}

private extension NSRect {
    func constrained(to bounds: NSRect) -> NSRect {
        var result = self
        result.size.width = min(width, bounds.width)
        result.size.height = min(height, bounds.height)
        result.origin.x = min(max(minX, bounds.minX), bounds.maxX - result.width)
        result.origin.y = min(max(minY, bounds.minY), bounds.maxY - result.height)
        return result
    }
}

@MainActor
final class ReminderPanelController {
    private weak var model: AppModel?
    private var panel: NSPanel?

    init(model: AppModel) {
        self.model = model
    }

    func show() {
        guard let model else { return }
        if panel == nil {
            let panel = FocusablePanel(
                contentRect: NSRect(x: 0, y: 0, width: 360, height: 350),
                styleMask: [.nonactivatingPanel, .hudWindow, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.isMovableByWindowBackground = true
            panel.becomesKeyOnlyIfNeeded = true
            panel.hidesOnDeactivate = false
            panel.titleVisibility = .hidden
            panel.titlebarAppearsTransparent = true
            panel.backgroundColor = .clear
            panel.isOpaque = false
            panel.hasShadow = true
            panel.contentView = NSHostingView(rootView: ReminderView(model: model))
            self.panel = panel
        }

        positionPanel()
        NSApplication.shared.activate(ignoringOtherApps: true)
        panel?.makeKeyAndOrderFront(nil)
    }

    func close() {
        panel?.orderOut(nil)
    }

    func focusForTyping() {
        panel?.makeKeyAndOrderFront(nil)
    }

    private func positionPanel() {
        guard let panel else { return }
        let pointer = NSEvent.mouseLocation
        let screen = NSScreen.screens.first(where: { NSMouseInRect(pointer, $0.frame, false) }) ?? NSScreen.main
        guard let visible = screen?.visibleFrame else { return }
        panel.contentView?.layoutSubtreeIfNeeded()

        let fittingSize = panel.contentView?.fittingSize ?? panel.frame.size
        let size = NSSize(
            width: max(panel.frame.width, fittingSize.width),
            height: max(panel.frame.height, fittingSize.height)
        )
        let proposedFrame = NSRect(
            x: visible.maxX - size.width - 18,
            y: visible.maxY - size.height - 18,
            width: size.width,
            height: size.height
        )
        let safeFrame = panel.constrainFrameRect(proposedFrame, to: screen)
        panel.setFrame(safeFrame, display: true)
    }
}

struct ReminderView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        if let activity = model.currentActivity {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(activity.category.title, systemImage: activity.category.symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(color(for: activity.category))
                    Spacer()
                    Text(activity.format.durationText)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Text(activity.title)
                    .font(.title2.weight(.semibold))

                Text(activity.instruction)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)

                if let safety = activity.safetyLine {
                    Text(safety)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                content(for: activity)
            }
            .padding(20)
            .frame(width: 360)
            .frame(minHeight: 260)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.regularMaterial)
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(popupGradient(
                        for: activity.category,
                        mode: model.popupColorMode,
                        fixedTheme: model.popupTheme
                    ))
                    .opacity(0.55)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(.white.opacity(0.15))
            }
        }
    }

    @ViewBuilder
    private func content(for activity: ActivityDefinition) -> some View {
        switch model.breakPhase {
        case .due:
            HStack {
                Text("Starting automatically")
                    .font(.headline)
                Spacer()
                Text("\(model.autoStartCountdown)")
                    .font(.system(size: 34, weight: .bold, design: .rounded).monospacedDigit())
                    .contentTransition(.numericText())
            }

            HStack {
                Button("Swap") { model.swapCurrentActivity() }
                Button("Eye break") { model.showEyeActivity() }
                Button("Next") { model.nextTask() }
            }
            .buttonStyle(.bordered)

            Text("⌃S Swap   ·   ⌃E Eyes   ·   ⌃N Next")
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            HStack {
                Button("Snooze 5 min") { model.snoozeCurrentActivity() }
                Spacer()
                Menu("More") {
                    Button("Skip") { model.skipCurrentActivity() }
                    Button("Hide this activity") { model.hideCurrentActivity() }
                    if model.lastHiddenActivity != nil {
                        Button("Undo hide") { model.undoLastHiddenActivity() }
                    }
                }
            }
            .buttonStyle(.borderless)

        case .active:
            if case .writing = activity.format {
                TextField("Type here…", text: $model.writingText)
                    .textFieldStyle(.roundedBorder)
            }
            HStack {
                Text(model.remainingSeconds > 0 ? "\(model.remainingSeconds)s" : "Ready")
                    .font(.system(size: 34, weight: .semibold, design: .rounded).monospacedDigit())
                Spacer()
                if model.revealAvailable {
                    Button(completionTitle(for: activity)) { model.completeCurrentActivityNow() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .disabled(!model.canCompleteCurrentActivity)
                }
                Button("End") { model.skipCurrentActivity() }
                    .buttonStyle(.borderless)
            }

            if model.revealAvailable {
                Text(model.canCompleteCurrentActivity ? "⌃D Complete" : "Type something, then press ⌃D")
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }

        case .completed:
            PointsAwardView(
                points: model.lastAward,
                category: activity.category,
                answer: activity.answer
            )
        }
    }

    private func completionTitle(for activity: ActivityDefinition) -> String {
        if case .brainSpark = activity.format { return "Reveal & complete" }
        return "Complete"
    }
}

func color(for category: ActivityCategory) -> Color {
    switch category {
    case .eyes: Color(red: 0.78, green: 0.22, blue: 0.24)
    case .movement: .orange
    case .mobility: Color(red: 0.68, green: 0.45, blue: 0.08)
    case .calm: Color(red: 0.23, green: 0.49, blue: 0.76)
    case .hydration: Color(red: 0.08, green: 0.56, blue: 0.64)
    case .brain: Color(red: 0.48, green: 0.31, blue: 0.72)
    case .voice: Color(red: 0.72, green: 0.27, blue: 0.53)
    case .writing: .indigo
    case .rhythm: Color(red: 0.76, green: 0.35, blue: 0.20)
    case .mindfulness: .green
    case .affirmations: Color(red: 0.58, green: 0.36, blue: 0.18)
    }
}

private func popupGradient(
    for category: ActivityCategory,
    mode: PopupColorMode,
    fixedTheme: PopupTheme
) -> LinearGradient {
    if mode == .category {
        return LinearGradient(
            colors: categoryPopupColors(for: category),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    let colors: [Color]
    switch fixedTheme {
    case .coral: colors = [Color(red: 1, green: 0.48, blue: 0.45), Color(red: 0.95, green: 0.68, blue: 0.55)]
    case .ocean: colors = [Color(red: 0.25, green: 0.67, blue: 0.92), Color(red: 0.30, green: 0.83, blue: 0.78)]
    case .forest: colors = [Color(red: 0.32, green: 0.72, blue: 0.48), Color(red: 0.62, green: 0.78, blue: 0.40)]
    case .plum: colors = [Color(red: 0.68, green: 0.45, blue: 0.86), Color(red: 0.92, green: 0.48, blue: 0.70)]
    case .graphite: colors = [Color.gray.opacity(0.75), Color.gray.opacity(0.38)]
    }
    return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
}

private func categoryPopupColors(for category: ActivityCategory) -> [Color] {
    switch category {
    case .eyes:
        [Color(red: 0.96, green: 0.42, blue: 0.42), Color(red: 1.00, green: 0.67, blue: 0.58)]
    case .movement:
        [Color(red: 0.97, green: 0.58, blue: 0.27), Color(red: 1.00, green: 0.77, blue: 0.43)]
    case .mobility:
        [Color(red: 0.92, green: 0.69, blue: 0.28), Color(red: 0.96, green: 0.83, blue: 0.48)]
    case .calm:
        [Color(red: 0.41, green: 0.68, blue: 0.91), Color(red: 0.58, green: 0.81, blue: 0.91)]
    case .hydration:
        [Color(red: 0.24, green: 0.74, blue: 0.79), Color(red: 0.49, green: 0.87, blue: 0.81)]
    case .brain:
        [Color(red: 0.62, green: 0.49, blue: 0.86), Color(red: 0.80, green: 0.67, blue: 0.92)]
    case .voice:
        [Color(red: 0.88, green: 0.45, blue: 0.68), Color(red: 0.96, green: 0.68, blue: 0.79)]
    case .writing:
        [Color(red: 0.46, green: 0.50, blue: 0.84), Color(red: 0.67, green: 0.70, blue: 0.94)]
    case .rhythm:
        [Color(red: 0.92, green: 0.47, blue: 0.30), Color(red: 0.97, green: 0.67, blue: 0.48)]
    case .mindfulness:
        [Color(red: 0.40, green: 0.70, blue: 0.48), Color(red: 0.65, green: 0.82, blue: 0.58)]
    case .affirmations:
        [Color(red: 0.79, green: 0.59, blue: 0.38), Color(red: 0.91, green: 0.76, blue: 0.55)]
    }
}

private struct PointsAwardView: View {
    let points: Int
    let category: ActivityCategory
    let answer: String?
    @State private var animate = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color(for: category).opacity(0.20))
                    .frame(width: 58, height: 58)
                    .scaleEffect(animate ? 1.18 : 0.55)
                    .opacity(animate ? 0 : 1)
                Image(systemName: category.symbol)
                    .font(.system(size: 27, weight: .semibold))
                    .foregroundStyle(color(for: category))
                    .scaleEffect(animate ? 1 : 0.45)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("+\(points) points")
                    .font(.title2.bold())
                Text(category.title)
                    .font(.headline)
                    .foregroundStyle(color(for: category))
                if let answer {
                    Text(answer).font(.caption).foregroundStyle(.secondary)
                } else {
                    Text("Added immediately").font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .onAppear {
            if reduceMotion {
                animate = true
            } else {
                withAnimation(.spring(response: 0.42, dampingFraction: 0.62)) {
                    animate = true
                }
            }
        }
    }
}
