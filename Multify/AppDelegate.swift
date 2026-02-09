import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: OverlayWindow?
    let sessionManager = SessionManager()

    func applicationDidFinishLaunching(_ notification: Notification) {

        let overlayView = OverlayView()
            .environmentObject(sessionManager)

        let window = OverlayWindow(contentView: overlayView)
        window.makeKeyAndOrderFront(nil)

        self.window = window
    }
}
