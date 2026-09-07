import AppKit

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: CreateIconFromDMGMotif.swift dmg-background.png output.png\n", stderr)
    exit(2)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])

guard let source = NSImage(contentsOf: inputURL),
      let sourceRep = NSBitmapImageRep(data: try Data(contentsOf: inputURL)),
      sourceRep.pixelsWide == 1440,
      sourceRep.pixelsHigh == 920 else {
    fputs("Expected the 1440 x 920 NanoBreaks DMG background.\n", stderr)
    exit(2)
}

let iconSize = 1024
guard let outputRep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: iconSize,
    pixelsHigh: iconSize,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fputs("Could not create the icon canvas.\n", stderr)
    exit(2)
}

let canvasSize = NSSize(width: iconSize, height: iconSize)
outputRep.size = canvasSize

let cropX = 500
let cropY = 220
let cropWidth = 440
let cropHeight = 230
guard let motifRep = NSBitmapImageRep(
    bitmapDataPlanes: nil,
    pixelsWide: cropWidth,
    pixelsHigh: cropHeight,
    bitsPerSample: 8,
    samplesPerPixel: 4,
    hasAlpha: true,
    isPlanar: false,
    colorSpaceName: .deviceRGB,
    bytesPerRow: 0,
    bitsPerPixel: 0
) else {
    fputs("Could not create the motif layer.\n", stderr)
    exit(2)
}

let paperRed = CGFloat(254) / 255
let paperGreen = CGFloat(248) / 255
let paperBlue = CGFloat(239) / 255
for y in 0..<cropHeight {
    for x in 0..<cropWidth {
        guard let sourceColor = sourceRep.colorAt(x: cropX + x, y: cropY + y)?.usingColorSpace(.deviceRGB) else { continue }
        let redDelta = sourceColor.redComponent - paperRed
        let greenDelta = sourceColor.greenComponent - paperGreen
        let blueDelta = sourceColor.blueComponent - paperBlue
        let distance = sqrt(redDelta * redDelta + greenDelta * greenDelta + blueDelta * blueDelta)
        let opacity = max(0, min(1, (distance - 0.045) / 0.09))
        motifRep.setColor(
            NSColor(
                deviceRed: sourceColor.redComponent,
                green: sourceColor.greenComponent,
                blue: sourceColor.blueComponent,
                alpha: opacity
            ),
            atX: x,
            y: y
        )
    }
}
motifRep.size = NSSize(width: cropWidth, height: cropHeight)
let motifImage = NSImage(size: motifRep.size)
motifImage.addRepresentation(motifRep)

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: outputRep)
NSColor.clear.setFill()
NSRect(origin: .zero, size: canvasSize).fill()

let squircle = NSBezierPath(
    roundedRect: NSRect(x: 20, y: 20, width: 984, height: 984),
    xRadius: 210,
    yRadius: 210
)
squircle.addClip()
NSColor(calibratedRed: paperRed, green: paperGreen, blue: paperBlue, alpha: 1.0).setFill()
NSRect(origin: .zero, size: canvasSize).fill()

let motifDestination = NSRect(x: 62, y: 277, width: 900, height: 470)
motifImage.draw(
    in: motifDestination,
    from: NSRect(x: 0, y: 0, width: cropWidth, height: cropHeight),
    operation: .sourceOver,
    fraction: 1,
    respectFlipped: false,
    hints: [.interpolation: NSImageInterpolation.high]
)
NSGraphicsContext.restoreGraphicsState()

guard let png = outputRep.representation(using: .png, properties: [:]) else {
    fputs("Could not encode the icon PNG.\n", stderr)
    exit(2)
}
try png.write(to: outputURL, options: .atomic)
