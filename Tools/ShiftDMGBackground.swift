import AppKit

guard CommandLine.arguments.count == 4,
      let shift = Double(CommandLine.arguments[3]) else {
    fputs("Usage: ShiftDMGBackground.swift input.png output.png shiftPixels\n", stderr)
    exit(2)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])

guard let source = NSImage(contentsOf: inputURL),
      let sourceRep = NSBitmapImageRep(data: try Data(contentsOf: inputURL)) else {
    fputs("Could not read the source PNG.\n", stderr)
    exit(2)
}

let width = sourceRep.pixelsWide
let height = sourceRep.pixelsHigh
guard let outputRep = NSBitmapImageRep(
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
) else {
    fputs("Could not create the output canvas.\n", stderr)
    exit(2)
}

let canvasSize = NSSize(width: width, height: height)
source.size = canvasSize
outputRep.size = canvasSize

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: outputRep)
NSColor(calibratedRed: 1.0, green: 0.984, blue: 0.957, alpha: 1.0).setFill()
NSRect(x: 0, y: 0, width: width, height: height).fill()
source.draw(
    in: NSRect(x: 0, y: shift, width: Double(width), height: Double(height)),
    from: NSRect(x: 0, y: 0, width: Double(width), height: Double(height)),
    operation: .copy,
    fraction: 1.0,
    respectFlipped: false,
    hints: [.interpolation: NSImageInterpolation.none]
)
NSGraphicsContext.restoreGraphicsState()

guard let png = outputRep.representation(using: .png, properties: [:]) else {
    fputs("Could not encode the output PNG.\n", stderr)
    exit(2)
}
try png.write(to: outputURL)
