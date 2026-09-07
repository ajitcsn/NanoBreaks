import AppKit

guard CommandLine.arguments.count == 3 else {
    fputs("Usage: MaskAppIcon.swift input.png output.png\n", stderr)
    exit(2)
}

let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
let outputURL = URL(fileURLWithPath: CommandLine.arguments[2])

guard let source = NSImage(contentsOf: inputURL),
      let sourceRep = NSBitmapImageRep(data: try Data(contentsOf: inputURL)) else {
    fputs("Could not read the source icon.\n", stderr)
    exit(2)
}

let width = sourceRep.pixelsWide
let height = sourceRep.pixelsHigh
guard width == height,
      let outputRep = NSBitmapImageRep(
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
    fputs("The source must be a square PNG.\n", stderr)
    exit(2)
}

let canvas = NSSize(width: width, height: height)
source.size = canvas
outputRep.size = canvas

NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: outputRep)
NSColor.clear.setFill()
NSRect(origin: .zero, size: canvas).fill()

let inset = CGFloat(width) * 0.018
let maskBounds = NSRect(origin: .zero, size: canvas).insetBy(dx: inset, dy: inset)
let cornerRadius = CGFloat(width) * 0.205
NSBezierPath(roundedRect: maskBounds, xRadius: cornerRadius, yRadius: cornerRadius).addClip()
source.draw(
    in: NSRect(origin: .zero, size: canvas),
    from: NSRect(origin: .zero, size: canvas),
    operation: .sourceOver,
    fraction: 1,
    respectFlipped: false,
    hints: [.interpolation: NSImageInterpolation.high]
)
NSGraphicsContext.restoreGraphicsState()

guard let png = outputRep.representation(using: .png, properties: [:]) else {
    fputs("Could not encode the masked icon.\n", stderr)
    exit(2)
}
try png.write(to: outputURL, options: .atomic)
