#!/usr/bin/env swift

import AppKit
import Foundation

// Generates AppIcon.icns programmatically
// A shipping container with a terminal window — dark theme, blue accent

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let s = size / 512.0 // scale factor

    // --- Background: rounded rect ---
    let bgRect = CGRect(x: 0, y: 0, width: size, height: size)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: 112 * s, cornerHeight: 112 * s, transform: nil)
    ctx.addPath(bgPath)
    ctx.clip()

    // Gradient background
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bgColors = [
        CGColor(red: 0.102, green: 0.102, blue: 0.180, alpha: 1.0),
        CGColor(red: 0.086, green: 0.129, blue: 0.243, alpha: 1.0),
    ]
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: bgColors as CFArray, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size), end: CGPoint(x: size, y: 0), options: [])
    }

    // --- Container box ---
    let boxRect = CGRect(x: 96 * s, y: (512 - 370) * s, width: 320 * s, height: 220 * s)
    let boxPath = CGPath(roundedRect: boxRect, cornerWidth: 20 * s, cornerHeight: 20 * s, transform: nil)

    // Box gradient (blue)
    ctx.saveGState()
    ctx.addPath(boxPath)
    ctx.clip()
    let boxColors = [
        CGColor(red: 0.0, green: 0.824, blue: 1.0, alpha: 0.9),
        CGColor(red: 0.227, green: 0.482, blue: 0.835, alpha: 0.9),
    ]
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: boxColors as CFArray, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(gradient, start: CGPoint(x: boxRect.minX, y: boxRect.maxY), end: CGPoint(x: boxRect.maxX, y: boxRect.minY), options: [])
    }

    // Container ridges
    ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.25))
    ctx.setLineWidth(2 * s)
    for xOffset in [160.0, 256.0, 352.0] {
        ctx.move(to: CGPoint(x: xOffset * s, y: boxRect.minY))
        ctx.addLine(to: CGPoint(x: xOffset * s, y: boxRect.maxY))
        ctx.strokePath()
    }
    ctx.restoreGState()

    // Box stroke
    ctx.addPath(boxPath)
    ctx.setStrokeColor(CGColor(red: 0.0, green: 0.824, blue: 1.0, alpha: 0.4))
    ctx.setLineWidth(2 * s)
    ctx.strokePath()

    // --- Terminal screen ---
    let screenRect = CGRect(x: 126 * s, y: (512 - 340) * s, width: 260 * s, height: 160 * s)
    let screenPath = CGPath(roundedRect: screenRect, cornerWidth: 10 * s, cornerHeight: 10 * s, transform: nil)

    ctx.saveGState()
    ctx.addPath(screenPath)
    ctx.clip()
    let screenColors = [
        CGColor(red: 0.059, green: 0.204, blue: 0.376, alpha: 1.0),
        CGColor(red: 0.102, green: 0.102, blue: 0.180, alpha: 1.0),
    ]
    if let gradient = CGGradient(colorsSpace: colorSpace, colors: screenColors as CFArray, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(gradient, start: CGPoint(x: screenRect.minX, y: screenRect.maxY), end: CGPoint(x: screenRect.maxX, y: screenRect.minY), options: [])
    }
    ctx.restoreGState()

    // --- Traffic lights (top of screen, macOS style) ---
    // In CoreGraphics, y=0 is bottom, so "top" of screen = higher y
    let tlY = screenRect.maxY - 16 * s
    let tlRadius = 5 * s
    let trafficLights: [(x: CGFloat, color: CGColor)] = [
        (142 * s, CGColor(red: 1.0, green: 0.373, blue: 0.341, alpha: 1.0)),
        (156 * s, CGColor(red: 0.996, green: 0.737, blue: 0.180, alpha: 1.0)),
        (170 * s, CGColor(red: 0.157, green: 0.784, blue: 0.251, alpha: 1.0)),
    ]
    for tl in trafficLights {
        ctx.setFillColor(tl.color)
        ctx.fillEllipse(in: CGRect(x: tl.x - tlRadius, y: tlY - tlRadius, width: tlRadius * 2, height: tlRadius * 2))
    }

    // --- Terminal text lines ---
    let lineColors: [CGColor] = [
        CGColor(red: 0.0, green: 0.824, blue: 1.0, alpha: 0.8),   // cyan
        CGColor(red: 0.914, green: 0.271, blue: 0.376, alpha: 0.6), // red
        CGColor(red: 0.0, green: 0.824, blue: 1.0, alpha: 0.5),   // cyan dim
        CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3),     // white dim
        CGColor(red: 0.0, green: 0.824, blue: 1.0, alpha: 0.6),   // cyan
        CGColor(red: 0.914, green: 0.271, blue: 0.376, alpha: 0.4), // red dim
    ]
    let lineWidths: [CGFloat] = [70, 110, 90, 130, 55, 100]

    let lineStartY = screenRect.maxY - 36 * s
    let lineX = 142 * s
    let lineH = 5 * s
    let lineSpacing = 16 * s

    for i in 0..<6 {
        let y = lineStartY - CGFloat(i) * lineSpacing
        ctx.setFillColor(lineColors[i])
        let rect = CGRect(x: lineX, y: y, width: lineWidths[i] * s, height: lineH)
        let path = CGPath(roundedRect: rect, cornerWidth: 2.5 * s, cornerHeight: 2.5 * s, transform: nil)
        ctx.addPath(path)
        ctx.fillPath()
    }

    // --- Cursor blink ---
    let cursorY = lineStartY - 6 * lineSpacing
    ctx.setFillColor(CGColor(red: 0.0, green: 0.824, blue: 1.0, alpha: 0.9))
    ctx.fill(CGRect(x: lineX, y: cursorY, width: 10 * s, height: lineH))

    image.unlockFocus()
    return image
}

func createIconset(at path: String) throws {
    let fm = FileManager.default
    let iconsetPath = path + "/AppIcon.iconset"
    try fm.createDirectory(atPath: iconsetPath, withIntermediateDirectories: true)

    let sizes: [(name: String, size: CGFloat)] = [
        ("icon_16x16", 16),
        ("icon_16x16@2x", 32),
        ("icon_32x32", 32),
        ("icon_32x32@2x", 64),
        ("icon_128x128", 128),
        ("icon_128x128@2x", 256),
        ("icon_256x256", 256),
        ("icon_256x256@2x", 512),
        ("icon_512x512", 512),
        ("icon_512x512@2x", 1024),
    ]

    for entry in sizes {
        let image = drawIcon(size: entry.size)
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            print("Failed to create PNG for \(entry.name)")
            continue
        }
        let filePath = iconsetPath + "/\(entry.name).png"
        try png.write(to: URL(fileURLWithPath: filePath))
    }

    // Convert iconset to icns
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    process.arguments = ["-c", "icns", iconsetPath, "-o", path + "/AppIcon.icns"]
    try process.run()
    process.waitUntilExit()

    if process.terminationStatus == 0 {
        try? fm.removeItem(atPath: iconsetPath)
        print("Created AppIcon.icns at \(path)/AppIcon.icns")
    } else {
        print("iconutil failed with status \(process.terminationStatus)")
    }
}

// Main
let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."
do {
    try createIconset(at: outputDir)
} catch {
    print("Error: \(error)")
    exit(1)
}
