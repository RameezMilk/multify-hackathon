import AppKit
import SwiftUI

final class OverlayWindow: NSWindow {

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    init<Content: View>(contentView: Content) {
        super.init(
            contentRect: NSRect(x: 300, y: 300, width: 340, height: 60),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        level = .floating
        hasShadow = true
        isMovableByWindowBackground = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        contentViewController = NSViewController()
        contentViewController?.view = NSHostingView(rootView: contentView)
    }
}
