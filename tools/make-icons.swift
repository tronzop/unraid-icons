// usage: swift make-icons.swift <src dir> <out dir>
import AppKit

let src = CommandLine.arguments[1], out = CommandLine.arguments[2]
let px: CGFloat = 512

func render(_ name: String, _ draw: (NSRect) -> Void) {
    let ctx = CGContext(data: nil, width: Int(px), height: Int(px), bitsPerComponent: 8, bytesPerRow: 0,
                        space: CGColorSpace(name: CGColorSpace.sRGB)!,
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: ctx, flipped: false)
    draw(NSRect(x: 0, y: 0, width: px, height: px))
    NSGraphicsContext.restoreGraphicsState()
    let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(out)/\(name).png"))
}

func img(_ f: String) -> NSImage { NSImage(contentsOfFile: "\(src)/\(f).png")! }

/// Fits an image into rect keeping aspect ratio.
func drawFit(_ i: NSImage, in r: NSRect) {
    let s = min(r.width / i.size.width, r.height / i.size.height)
    let w = i.size.width * s, h = i.size.height * s
    i.draw(in: NSRect(x: r.midX - w / 2, y: r.midY - h / 2, width: w, height: h))
}

/// App icons are full-bleed squares; round them like a home-screen tile.
func appTile(_ i: NSImage, _ r: NSRect) {
    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: r, xRadius: r.width * 0.22, yRadius: r.width * 0.22).addClip()
    i.draw(in: r)
    NSGraphicsContext.restoreGraphicsState()
}

func symbol(_ name: String, _ r: NSRect, _ color: NSColor, weight: NSFont.Weight = .semibold) {
    let cfg = NSImage.SymbolConfiguration(pointSize: r.height, weight: weight)
        .applying(.init(paletteColors: [color]))
    let s = NSImage(systemSymbolName: name, accessibilityDescription: nil)!.withSymbolConfiguration(cfg)!
    drawFit(s, in: r)
}

/// Bottom-right circular badge over an app tile.
func badge(_ fill: NSColor, _ content: (NSRect) -> Void) {
    let d: CGFloat = 230
    let r = NSRect(x: px - d - 4, y: 4, width: d, height: d)
    NSColor.white.setFill(); NSBezierPath(ovalIn: r).fill()
    fill.setFill(); NSBezierPath(ovalIn: r.insetBy(dx: 12, dy: 12)).fill()
    content(r.insetBy(dx: 52, dy: 52))
}

func gradientTile(_ a: NSColor, _ b: NSColor, _ r: NSRect) {
    let p = NSBezierPath(roundedRect: r, xRadius: r.width * 0.22, yRadius: r.width * 0.22)
    NSGradient(starting: a, ending: b)!.draw(in: p, angle: -90)
}

func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor { NSColor(srgbRed: r / 255, green: g / 255, blue: b / 255, alpha: 1) }

func label(_ text: String, _ r: NSRect, size: CGFloat, color: NSColor = .white) {
    let p = NSMutableParagraphStyle(); p.alignment = .center
    let a: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: size, weight: .heavy),
                                            .foregroundColor: color, .paragraphStyle: p]
    let s = NSAttributedString(string: text, attributes: a)
    let h = s.size().height
    s.draw(in: NSRect(x: r.minX, y: r.midY - h / 2, width: r.width, height: h))
}

// Own apps: their real app icons.
render("unraid-controller") { appTile(img("unraid-controller"), $0) }
render("notes-api") { appTile(img("notes"), $0) }
render("tvremote") { appTile(img("cube-remote"), $0) }

// Variants: the parent app's icon with a badge saying what this container does.
render("notes-db") { r in
    appTile(img("notes"), r.insetBy(dx: 0, dy: 0))
    badge(.white) { drawFit(img("postgres"), in: $0.insetBy(dx: -18, dy: -18)) }
}
render("notes-migrate") { r in
    appTile(img("notes"), r)
    badge(rgb(52, 120, 246)) { symbol("arrow.up", $0, .white, weight: .bold) }
}
render("ps-library-sync") { r in
    appTile(img("ps-library"), r)
    badge(rgb(48, 176, 92)) { symbol("arrow.triangle.2.circlepath", $0, .white, weight: .bold) }
}

// Custom tiles for containers without a brand.
render("chdman") { r in
    gradientTile(rgb(110, 72, 200), rgb(46, 28, 96), r)
    symbol("opticaldisc", NSRect(x: 106, y: 170, width: 300, height: 260), .white, weight: .regular)
    label("CHD", NSRect(x: 0, y: 50, width: px, height: 120), size: 104)
}
render("tailnet-sites") { r in
    gradientTile(rgb(64, 72, 88), rgb(18, 20, 26), r)
    symbol("globe", NSRect(x: 106, y: 170, width: 300, height: 260), .white, weight: .regular)
    label("TAILNET", NSRect(x: 0, y: 50, width: px, height: 120), size: 84)
}
render("whisper") { r in
    gradientTile(rgb(20, 184, 166), rgb(14, 90, 110), r)
    symbol("waveform", r.insetBy(dx: 96, dy: 96), .white)
}
render("whisper-asr") { r in
    gradientTile(rgb(236, 72, 153), rgb(120, 30, 90), r)
    symbol("waveform.and.mic", NSRect(x: 86, y: 170, width: 340, height: 270), .white)
    label("ASR", NSRect(x: 0, y: 50, width: px, height: 120), size: 104)
}

// Brands: official artwork, centred on a transparent square.
for (name, file) in [("mosquitto", "mosquitto"), ("StirlingPDF", "stirling-pdf"),
                     ("rawe-ceek-watchtower", "watchtower"), ("upsnap", "upsnap")] {
    render(name) { drawFit(img(file), in: $0.insetBy(dx: 16, dy: 16)) }
}
render("TimeMachine") { r in
    gradientTile(rgb(52, 199, 89), rgb(18, 96, 52), r)
    symbol("clock.arrow.trianglehead.counterclockwise.rotate.90", r.insetBy(dx: 92, dy: 92), .white)
}
render("forgejo") { drawFit(img("forgejo"), in: $0.insetBy(dx: 16, dy: 16)) }
render("forgejo-runner") { r in
    drawFit(img("forgejo"), in: r.insetBy(dx: 16, dy: 16))
    badge(rgb(48, 176, 92)) { symbol("play.fill", $0, .white, weight: .bold) }
}
