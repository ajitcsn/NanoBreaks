import AppKit

private extension NSColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            calibratedRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}

private let cream = NSColor(hex: 0xFBF7EF)
private let ink = NSColor(hex: 0x30263A)
private let sage = NSColor(hex: 0x6F9279)
private let paleSage = NSColor(hex: 0xDDE8DE)
private let apricot = NSColor(hex: 0xE7A184)
private let paleApricot = NSColor(hex: 0xF5DED2)

private func bitmap(width: Int, height: Int, draw: () -> Void) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: width, height: height)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    draw()
    NSGraphicsContext.restoreGraphicsState()
    return rep
}

private func point(onCircle center: NSPoint, radius: CGFloat, degrees: CGFloat) -> NSPoint {
    let radians = degrees * .pi / 180
    return NSPoint(x: center.x + cos(radians) * radius, y: center.y + sin(radians) * radius)
}

private func drawLeaf(base: NSPoint, tip: NSPoint, width: CGFloat, color: NSColor) {
    let dx = tip.x - base.x
    let dy = tip.y - base.y
    let length = max(1, hypot(dx, dy))
    let px = -dy / length * width
    let py = dx / length * width

    let leaf = NSBezierPath()
    leaf.move(to: base)
    leaf.curve(
        to: tip,
        controlPoint1: NSPoint(x: base.x + dx * 0.30 + px, y: base.y + dy * 0.30 + py),
        controlPoint2: NSPoint(x: base.x + dx * 0.76 + px * 0.78, y: base.y + dy * 0.76 + py * 0.78)
    )
    leaf.curve(
        to: base,
        controlPoint1: NSPoint(x: base.x + dx * 0.76 - px * 0.78, y: base.y + dy * 0.76 - py * 0.78),
        controlPoint2: NSPoint(x: base.x + dx * 0.30 - px, y: base.y + dy * 0.30 - py)
    )
    leaf.close()
    color.setFill()
    leaf.fill()
}

private func drawOpenRing(
    center: NSPoint,
    radius: CGFloat,
    lineWidth: CGFloat,
    color: NSColor
) {
    let ring = NSBezierPath()
    ring.appendArc(
        withCenter: center,
        radius: radius,
        startAngle: 78,
        endAngle: 390,
        clockwise: false
    )
    ring.lineWidth = lineWidth
    ring.lineCapStyle = .round
    color.setStroke()
    ring.stroke()

    let leafBase = point(onCircle: center, radius: radius, degrees: 78)
    let leafLength = radius * 0.42
    let leafTip = NSPoint(
        x: leafBase.x + leafLength * 0.76,
        y: leafBase.y + leafLength * 0.65
    )
    drawLeaf(base: leafBase, tip: leafTip, width: lineWidth * 0.48, color: color)
}

private func writePNG(_ rep: NSBitmapImageRep, to path: String) throws {
    let data = rep.representation(using: .png, properties: [:])!
    try data.write(to: URL(fileURLWithPath: path), options: .atomic)
}

private func centeredText(
    _ text: String,
    y: CGFloat,
    width: CGFloat,
    font: NSFont,
    color: NSColor,
    tracking: CGFloat = 0
) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph,
        .kern: tracking
    ]
    NSAttributedString(string: text, attributes: attributes).draw(
        in: NSRect(x: 0, y: y, width: width, height: font.pointSize * 1.5)
    )
}

guard CommandLine.arguments.count == 4 else {
    fputs("Usage: OpenRingBrandGenerator.swift icon.png dmg@2x.png dmg.png\n", stderr)
    exit(2)
}

let iconPath = CommandLine.arguments[1]
let dmg2xPath = CommandLine.arguments[2]
let dmgPath = CommandLine.arguments[3]

let icon = bitmap(width: 1024, height: 1024) {
    NSColor.clear.setFill()
    NSRect(x: 0, y: 0, width: 1024, height: 1024).fill()

    let tile = NSBezierPath(roundedRect: NSRect(x: 20, y: 20, width: 984, height: 984), xRadius: 215, yRadius: 215)
    cream.setFill()
    tile.fill()

    let halo = NSBezierPath(ovalIn: NSRect(x: 211, y: 179, width: 602, height: 602))
    halo.lineWidth = 24
    paleApricot.withAlphaComponent(0.48).setStroke()
    halo.stroke()

    drawOpenRing(center: NSPoint(x: 512, y: 480), radius: 252, lineWidth: 76, color: sage)
}

let dmg2x = bitmap(width: 1440, height: 920) {
    cream.setFill()
    NSRect(x: 0, y: 0, width: 1440, height: 920).fill()

    let upperWash = NSBezierPath(ovalIn: NSRect(x: -190, y: 610, width: 620, height: 430))
    paleSage.withAlphaComponent(0.33).setFill()
    upperWash.fill()
    let lowerWash = NSBezierPath(ovalIn: NSRect(x: 1090, y: -180, width: 520, height: 430))
    paleApricot.withAlphaComponent(0.38).setFill()
    lowerWash.fill()

    drawOpenRing(center: NSPoint(x: 520, y: 798), radius: 37, lineWidth: 11, color: sage)

    let titleFont = NSFont.systemFont(ofSize: 72, weight: .semibold)
    let title = NSAttributedString(string: "NanoBreaks", attributes: [
        .font: titleFont,
        .foregroundColor: ink,
        .kern: -1.5
    ])
    title.draw(at: NSPoint(x: 586, y: 754))

    centeredText(
        "small breaks for the mind, body, voice, and psyche",
        y: 700,
        width: 1440,
        font: NSFont.systemFont(ofSize: 27, weight: .medium),
        color: ink.withAlphaComponent(0.82)
    )

    centeredText(
        "DRAG TO INSTALL",
        y: 548,
        width: 1440,
        font: NSFont.systemFont(ofSize: 21, weight: .semibold),
        color: sage,
        tracking: 3.6
    )

    let leftWell = NSBezierPath(roundedRect: NSRect(x: 230, y: 170, width: 292, height: 292), xRadius: 66, yRadius: 66)
    paleSage.withAlphaComponent(0.43).setFill()
    leftWell.fill()
    leftWell.lineWidth = 3
    sage.withAlphaComponent(0.25).setStroke()
    leftWell.stroke()

    let rightWell = NSBezierPath(roundedRect: NSRect(x: 916, y: 170, width: 292, height: 292), xRadius: 66, yRadius: 66)
    paleApricot.withAlphaComponent(0.47).setFill()
    rightWell.fill()
    rightWell.lineWidth = 3
    apricot.withAlphaComponent(0.26).setStroke()
    rightWell.stroke()

    let arrow = NSBezierPath()
    arrow.move(to: NSPoint(x: 648, y: 316))
    arrow.line(to: NSPoint(x: 786, y: 316))
    arrow.move(to: NSPoint(x: 750, y: 282))
    arrow.line(to: NSPoint(x: 786, y: 316))
    arrow.line(to: NSPoint(x: 750, y: 350))
    arrow.lineWidth = 7
    arrow.lineCapStyle = .round
    arrow.lineJoinStyle = .round
    ink.setStroke()
    arrow.stroke()
}

let dmg1x = bitmap(width: 720, height: 460) {
    let source = NSImage(size: NSSize(width: 1440, height: 920))
    source.addRepresentation(dmg2x)
    source.draw(
        in: NSRect(x: 0, y: 0, width: 720, height: 460),
        from: NSRect(x: 0, y: 0, width: 1440, height: 920),
        operation: .copy,
        fraction: 1,
        respectFlipped: false,
        hints: [.interpolation: NSImageInterpolation.high]
    )
}

try writePNG(icon, to: iconPath)
try writePNG(dmg2x, to: dmg2xPath)
try writePNG(dmg1x, to: dmgPath)
