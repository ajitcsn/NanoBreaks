import AppKit
import SwiftUI

@MainActor
private let nanoBreaksMenuIcon: NSImage = {
    let image = NSImage(size: NSSize(width: 18, height: 18))
    image.lockFocus()

    let center = NSPoint(x: 8.7, y: 8.1)
    let radius: CGFloat = 5.7
    let startAngle: CGFloat = 78
    let ring = NSBezierPath()
    ring.appendArc(
        withCenter: center,
        radius: radius,
        startAngle: startAngle,
        endAngle: 390,
        clockwise: false
    )
    ring.lineWidth = 2.1
    ring.lineCapStyle = .round
    NSColor.black.setStroke()
    ring.stroke()

    let angle = startAngle * .pi / 180
    let base = NSPoint(
        x: center.x + cos(angle) * radius,
        y: center.y + sin(angle) * radius
    )
    let tip = NSPoint(x: base.x + 2.0, y: base.y + 1.8)
    let dx = tip.x - base.x
    let dy = tip.y - base.y
    let length = hypot(dx, dy)
    let px = -dy / length * 0.72
    let py = dx / length * 0.72
    let leaf = NSBezierPath()
    leaf.move(to: base)
    leaf.curve(
        to: tip,
        controlPoint1: NSPoint(x: base.x + dx * 0.3 + px, y: base.y + dy * 0.3 + py),
        controlPoint2: NSPoint(x: base.x + dx * 0.75 + px * 0.75, y: base.y + dy * 0.75 + py * 0.75)
    )
    leaf.curve(
        to: base,
        controlPoint1: NSPoint(x: base.x + dx * 0.75 - px * 0.75, y: base.y + dy * 0.75 - py * 0.75),
        controlPoint2: NSPoint(x: base.x + dx * 0.3 - px, y: base.y + dy * 0.3 - py)
    )
    leaf.close()
    NSColor.black.setFill()
    leaf.fill()

    image.unlockFocus()
    image.isTemplate = true
    return image
}()

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

@main
struct NanoBreaksApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(model: model)
        } label: {
            HStack(spacing: 4) {
                Image(nsImage: nanoBreaksMenuIcon)
                    .accessibilityHidden(true)
                Text(model.menuBarLabel)
            }
            .accessibilityLabel("NanoBreaks, \(model.menuBarLabel)")
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(model: model)
        }
    }
}
